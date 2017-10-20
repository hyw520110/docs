 前一段时间使用repair命令修复线上的数据库，发现数据库中碎片巨大，占用200多G的数据在repair之后只有50多G，然后就研究了一下Mongodb是如何利用已经删除了的空间的。

分析下源码（源码版本2.2.2,新版本可能随时更新）：
    
Mongodb在执行删除（文档）操作时，并不会进行物理删除，而是将他们放入每个命名空间维护的删除列表里。

	

    //pdfile.cpp delete()
           /* add to the free list */
            {
                    ....
                    d->addDeletedRec((DeletedRecord*)todelete, dl);
                }
            }




    //namespace_detail.cpp addDeletedRec(..)
           ....
           else {
                int b = bucket(d->lengthWithHeaders());
                DiskLoc& list = deletedList[b];
                DiskLoc oldHead = list;
                getDur().writingDiskLoc(list) = dloc;
                d->nextDeleted() = oldHead;
            }

上面的deletedList就是维护的删除数据列表。

	

    //namespace_detail.h
     /* deleted lists -- linked lists of deleted records -- are placed in 'buckets' of various sizes so you can look for a deleterecord about the right size.
     */
        const int Buckets = 19;
        const int MaxBucket = 18;
        DiskLoc deletedList[Buckets];
        int bucketSizes[] = { 32, 64, 128, 256, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000, 0x10000, 0x20000, 0x40000, 0x80000, 0x100000, 0x200000,0x400000, 0x800000};

 可以看到，deleteList数组实际保存的是DiskLoc，长度19，跟bucketSizes[]的长度一致。DiskLoc就是文档在磁盘上的位置，并且有后指针，可以指向下一个DiskLoc，从而组成一个列表。deleteList中实际就保存了19个列表，每个列表就是已经被删除文档地址，且这些文档都在bucketSizes所规定的的范围内。描述不太清楚，上图吧：

![image](http://blog.chinaunix.net/attachment/201303/29/15795819_13645488686e02.png)

插入文档时，Mongodb会先计算需要开辟多大的空间，然后去找deleteList中的位置，如果deleteList中不满足,那么才会去开辟新的空间。
	
	

    //pdfile.cpp
    int lenWHdr = d->getRecordAllocationSize( len + Record::HeaderSize );
    DiskLoc loc;
            if( addID || tableToIndex || d->isCapped() ) {
                // if need id, we don't do the early indexing. this is not the common case so that is sort of ok
                earlyIndex = false;
                loc = allocateSpaceForANewRecord(ns, d, lenWHdr, god);
            }
            else {
                loc = d->allocWillBeAt(ns, lenWHdr);
                if( loc.isNull() ) {
                    // need to get a new extent so we have to do the true alloc now (not common case)
                    earlyIndex = false;
                    loc = allocateSpaceForANewRecord(ns, d, lenWHdr, god);
                }
            }

我们暂时不讨论cappedCollection(固定大小的集合)，只看常规集合

	

    /* predetermine location of the next alloc without actually doing it.
            if cannot predetermine returns null (so still call alloc() then)
        */
        DiskLoc NamespaceDetails::allocWillBeAt(const char *ns, int lenToAlloc) {
            if ( ! isCapped() ) {
                lenToAlloc = (lenToAlloc + 3) & 0xfffffffc;
                return __stdAlloc(lenToAlloc, true);
            }
            return DiskLoc();
        }

     /* for non-capped collections.
           @param peekOnly just look up where and don't reserve
           returned item is out of the deleted list upon return
        */
        DiskLoc NamespaceDetails::__stdAlloc(int len, bool peekOnly) {
            DiskLoc *prev;
            DiskLoc *bestprev = 0;
            DiskLoc bestmatch;
            int bestmatchlen = 0x7fffffff;
            int b = bucket(len);
            DiskLoc cur = deletedList[b];
            prev = &deletedList[b];
            int extra = 5; // look for a better fit, a little.
            int chain = 0;
            while ( 1 ) {
                {
                    int a = cur.a();
                    if ( a < -1 || a >= 100000 ) {
                        problem() << "~~ Assertion - cur out of range in _alloc() " <<

    cur.toString() <<
                                  " a:" << a << " b:" << b << " chain:" << chain << '\n';
                        logContext();
                        if ( cur == *prev )
                            prev->Null();
                        cur.Null();
                    }
                }
                if ( cur.isNull() ) {
                    // move to next bucket. if we were doing "extra", just break
                    if ( bestmatchlen < 0x7fffffff )
                        break;
                    b++;
                    if ( b > MaxBucket ) {
                        // out of space. alloc a new extent.
                        return DiskLoc();
                    }
                    cur = deletedList[b];
                    prev = &deletedList[b];
                    continue;
                }
                DeletedRecord *r = cur.drec();
                if ( r->lengthWithHeaders() >= len &&
                     r->lengthWithHeaders() < bestmatchlen ) {
                    bestmatchlen = r->lengthWithHeaders();
                    bestmatch = cur;
                    bestprev = prev;
                }
                if ( bestmatchlen < 0x7fffffff && --extra <= 0 )
                    break;
                if ( ++chain > 30 && b < MaxBucket ) {
                    // too slow, force move to next bucket to grab a big chunk
                    //b++;
                    chain = 0;
                    cur.Null();
                }
                else {
                    /*this defensive check only made sense for the mmap storage engine:
                      if ( r->nextDeleted.getOfs() == 0 ) {
                        problem() << "~~ Assertion - bad nextDeleted " << r->nextDeleted.toString()

    <<
                        " b:" << b << " chain:" << chain << ", fixing.\n";
                        r->nextDeleted.Null();
                    }*/
                    cur = r->nextDeleted();
                    prev = &r->nextDeleted();
                }
            }

            /* unlink ourself from the deleted list */
            if( !peekOnly ) {
                DeletedRecord *bmr = bestmatch.drec();
                *getDur().writing(bestprev) = bmr->nextDeleted();
                bmr->nextDeleted().writing().setInvalid(); // defensive.
                verify(bmr->extentOfs() < bestmatch.getOfs());
            }

            return bestmatch;
        }

上面这段就是Mongodb在deleteList中寻找合适插入位置的算法.

    int b = bucket(len);
    DiskLoc cur = deletedList[b];

这是最初始的寻找位置的算法，解释一下，bucket函数就是寻找跟len（插入文档的大小）最接近的bucketSize，比如说len=68，那么应该在64-128这个范围内，在deleteList中应该是第3个列表，那么b=2,cur就是返回的第三个列表的起始位置。如果找到了，那么就是用列表中的值，如果找不到，就继续往下一个列表中寻找。找到之后，将找到的位置从deleteList中删除，返回。


如果所有的列表都遍历完成还是找不到，那么mongodb就会去硬盘上真的开辟一段空间。我们上面说过Mongodb会先计算需要开辟的空间大小，有两种方式

1、[doc's length + padding](http://docs.mongodb.org/manual/core/write-operations/#padding-factor)

2、[usePowerOf2Size](http://docs.mongodb.org/manual/reference/command/collMod/)

	

    //namespace_detail.cpp
    int NamespaceDetails::getRecordAllocationSize( int minRecordSize ) {
            if ( _paddingFactor == 0 ) {
                warning() << "implicit updgrade of paddingFactor of very old collection" << endl;
                setPaddingFactor(1.0);
            }
            verify( _paddingFactor >= 1 );


            if ( isUserFlagSet( Flag_UsePowerOf2Sizes ) ) {
                int allocationSize = bucketSizes[ bucket( minRecordSize ) ];
                if ( allocationSize < minRecordSize ) {
                    // if we get here, it means we're allocating more than 8mb
                    // the highest bucket is 8mb, so the above code will never return more than 8mb for allocationSize
                    // if this happens, we are going to round up to the nearest megabyte
                    fassert( 16439, bucket( minRecordSize ) == MaxBucket );
                    allocationSize = 1 + ( minRecordSize | ( ( 1 << 20 ) - 1 ) );
                }
                return allocationSize;
            }

            return static_cast<int>(minRecordSize * _paddingFactor);
        }

第一种padding方式，Mongodb会计算一个_paddingFactor，开辟doclen*(1+paddingFactor)大小，以防止update引起的长度变大，需要移动数据。第二种方式usePowerOf2Size，Mongodb为文档开辟的空间总是2的倍数，如之前我们说过的，文档大小68字节，那么就会开辟128字节，bucket函数就是从bucketSize数组中寻找最接近文档长度的那个2的次方值。

	

    //namespace_detail.cpp
     int bucketSizes[] = {
            32, 64, 128, 256, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000,
            0x8000, 0x10000, 0x20000, 0x40000, 0x80000, 0x100000, 0x200000,
            0x400000, 0x800000
        };

 这两种方式各有优劣，padding方式会为文档开辟更合适的大小，而且paddingFactor比较小，一般为0.01-0.09，不会浪费空间，文档更新小的话也不会移动文档位置。但是当大量更新和删除的时候，这种方式重复利用空间的能力就比较小，因为在deleteList中，不太容易找到合适的已删除文档，而且一旦更新就会又移动位置，磁盘重复利用率低，增长快，碎片多。相比之下，usePowerOf2Size方式，Mongodb每次都会开辟比文档大的多的空间，使用空间变多，但是更新和删除的容错率就会比较高，因为在deleteList列表中更容易找到合适的删除文档（每个列表中的文档大小都是相同的固定的），更新的时候也不会大量移动位置，磁盘重复利用率高，增长慢。


所以，在读操作较多的应用中，可以使用padding方式，也是mongodb默认的方式，在写操作较多的应用中，可以使用usePowerOf2Size方式。
usePowerOf2Size是在创建集合的时候指定的

	db.runCommand( {collMod: "products", usePowerOf2Sizes : true }) //enable
	db.runCommand( {collMod: "products", usePowerOf2Sizes : false })//disable
usePowerOf2Size只影响新插入和更新引起的分配空间大小，对之前的文档不起作用。

