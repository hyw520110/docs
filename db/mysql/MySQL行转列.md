	CREATE TABLE `example`(`id` INT, `order` INT, `data` VARCHAR(1));
	
	INSERT INTO `example` (`id`, `order`, `data`) 
	VALUES
	(1, 1, 'P'),
	(2, 2, 'Q'),
	(2, 1, 'R'),
	(1, 2, 'S');
	第一种写法
	SELECT 
	  id,
	  MAX(IF(`order` = 1, `data`, 0)) data1,
	  MAX(IF(`order` = 2, `data`, 0)) data2 
	FROM
	  `example` 
	GROUP BY id
	第二种写法
	SELECT 
	  id,
	  MAX(IF(`order` = 1, `data`, 0)) data1,
	  MAX(IF(`order` = 2, `data`, 0)) data2 
	FROM
	  `example` 
	WHERE id = 1 
	UNION
	SELECT 
	  id,
	  MAX(IF(`order` = 1, `data`, 0)) data1,
	  MAX(IF(`order` = 2, `data`, 0)) data2 
	FROM
	  `example` 
	WHERE id = 2 
	第三种写法
	SELECT 
	  e.id,
	  a.data,
	  e.data 
	FROM
	  `example` e 
	  INNER JOIN 
	    (SELECT 
	      * 
	    FROM
	      `example` e) a 
	    ON e.id = a.id 
	WHERE e.order != a.order 
	GROUP BY e.id
参考链接
http://stackoverflow.com/questions/14834290/mysql-query-to-dynamically-convert-rows-to-columns