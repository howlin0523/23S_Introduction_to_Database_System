show databases;

create database if not exists lab1;
use lab1;

drop table if exists course;
drop table if exists score;
drop table if exists student;
drop table if exists teacher;

create table if not exists course(
CNO char(8),
NAME varchar(50),
TNO char(7),
primary key(CNO)
);

create table if not exists score(
SNO char(12),
CNO char(8) ,
DEGREE int unsigned,
primary key(SNO, CNO)
);

create table if not exists student(
SNO char(12),
NAME varchar(4),
GENDER varchar(6), 
BIRTHDAY datetime,
DEPART int unsigned,
primary key(SNO)
);

create table if not exists teacher(
TNO char(12),
NAME varchar(4),
GENDER varchar(6),
BIRTHDAY datetime,
POSITION varchar(20),
DEPART int unsigned,
primary key(TNO)
);

desc student;

show variables like '%secure%';

SHOW GLOBAL VARIABLES LIKE 'local_infile';

load data infile './data/Course.csv'
into table course
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

load data infile './data/Score.csv'
into table score
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

load data infile './data/Student.csv'
into table student
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

load data infile './data/Teacher.csv'
into table teacher
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

select * from course;
select * from score;
select * from student;
select * from teacher;


/*markdown
## 修改基本表
*/

/*markdown
1、 在学生表 student 中增加一个新的属性列 AGE(年龄)，类型为 int。
*/

alter table student add age int;

/*markdown
2、计算每个学生的年龄(AGE)（简单用 2023 减去出生年份即可）。注意，此操作可能需要关闭安全更新模式；提示，可使用 MySQL 的 YEAR 函数。
*/

update student set age = 2023 - year(BIRTHDAY);

/*markdown
3、为每个学生的年龄加 2。
*/

update student set age = age + 2;

/*markdown
4、 将 AGE（年龄）的数据类型由 int 改为 char。
*/

alter table student modify age char(2);

/*markdown
5、 删除属性列 AGE。
*/

alter table student drop age;

/*markdown
6、 创建一个教师课程数量表： teacher_course(TNO,NUM_COURSE)，两个属性分别表示授课教师工号，课程数量，类型自定义(注意，这里 TNO 还不是主键)。
*/


drop table if exists teacher_course;
create table if not exists teacher_course(
TNO char(12),
NUM_COURSE int unsigned
);

/*markdown
7、 为表 teacher_course 添加主键(TNO)。
*/

alter table teacher_course add primary key(TNO);

/*markdown
8、 用一条语句，结合表 course 记录，为表 teacher 中所有教师，在表 teacher_course 添加对应记录（若是表 course 中未出现的教师，则课程数量记为 NULL）。
*/

insert into teacher_course (TNO, NUM_COURSE)
select t.TNO, if(count(c.CNO), count(c.CNO), null)
from teacher t 
left outer join course c on c.TNO = t.TNO
group by (t.TNO);

/*markdown
9、 删除表 teacher_course 中含有 NULL 的记录。
*/

delete from teacher_course where NUM_COURSE is null;

/*markdown
10、 删除表 teacher_course。
*/

drop table if exists teacher_course;

/*markdown
11、 在学生表 student 、成绩表 score 中分别插入一些数据
*/

insert into student(SNO, NAME, GENDER, BIRTHDAY, DEPART)
values 
('PB18061443', 'JHL', 'MALE', '2000-05-23 0:00', 229),
('PB20061376', 'GSB', 'MALE', '2002-07-02 0:00', 229),
('PB18061444', 'LGM', 'MALE', '2000-04-02 0:00', 229);

insert into score(SNO, CNO, DEGREE)
values 
('PB18061443', '20230402', 97),
('PB18061443', '20230410', 98),
('PB18061443', '20230412', 99);
-- select birthday from student where sno like 'PB18%';

/*markdown
12、在 score 表中删除你所选的课程中成绩最低的一门课程的记录
*/

DELETE FROM score
WHERE (SNO, DEGREE) = (
  SELECT SNO, min_degree
  FROM (
    SELECT SNO, MIN(DEGREE) as min_degree
    FROM score
    WHERE SNO = 'PB18061443'
  ) AS temp
  WHERE SNO = 'PB18061443'
)
LIMIT 1;

/*markdown
## 索引
*/

/*markdown
13、 用 create 语句在 course 表的名称 NAME 上建立普通索引 NAME_INDEX。
*/

create index NAME_INDEX on course(NAME);

/*markdown
14、 用 create 语句在 teacher 表的工号 TNO 上建立唯一索引 TNO_INDEX。
*/

create unique index TNO_INDEX on teacher(TNO);

/*markdown
15 、 用 create 语句在 score 表上的学号 SNO 、 成绩 DEGREE 上建立复合索RECORD_INDEX， 要求学号为降序，学号相同时成绩为升序。
*/

create index RECORD_INDEX on score(sno desc, degree asc);

/*markdown
16、 用一条语句查询表 score 的索引。
*/

show index from score;

/*markdown
17、 删除 teacher 表字段 TNO 上的索引 TNO_INDEX
*/

alter table teacher drop index TNO_INDEX;

/*markdown
## 查询
*/

/*markdown
18、 查询和你属于同一个系的学生学号和姓名(包括你本人)。
*/

select sno, name 
from student 
where depart = (
    select depart
    from student
    where name = 'JHL'
);

/*markdown
19、 查询和你属于同一个系的学生学号和姓名(不包括你本人)。
*/

select sno, name 
from student 
where depart = (
    select depart
    from student
    where sno = 'PB18061443'
)
and sno != 'PB18061443';

/*markdown
20、查询和你的某个好友属于同一个系的学生学号和姓名（11 题插入的某个好友）。
*/

select sno, name 
from student 
where depart = (
    select depart
    from student
    where name = 'LGM'
);

/*markdown
21、查询和你的两个好友都不在一个系的学生学号和姓名（11 题插入的两个好友）。
*/

select sno, name
from student
where depart not in (
    select depart
    from student
    where name in ('LGM', 'GSB')
);

/*markdown
22、 查询教过你的所有老师的工号和姓名。
*/

select distinct t.TNO, t.NAME
from teacher t
join course c on c.TNO = t.TNO
join score s on s.CNO = c.CNO
where s.SNO = 'PB18061443';

/*markdown
23、 查询 11 系和 229 系教师的总人数。
*/

select count(*)
from teacher
where depart in (11, 229)

/*markdown
24、 查询选修 DB_Design 课程且成绩在 89 分以上（包括 89）的学生的学号、姓名和分数。
*/

select stu.SNO, stu.NAME, s.DEGREE
from student stu
join score s on stu.SNO = s.SNO
join course c on c.CNO = s.CNO
where c.NAME = 'DB_Design' and s.DEGREE >= 89

/*markdown
25、 查询选修过“ZDH”老师课程的学生学号和姓名（去掉重复行）。
*/

select distinct stu.SNO, stu.NAME
from student stu
join score sc on sc.SNO = stu.SNO
join course c on c.CNO = sc.CNO
join teacher t on t.TNO = c.TNO
where t.NAME = 'ZDH';

/*markdown
26、 查询选过某课程的学生学号和分数，并按分数降序展示。（某课程是指 course 表中的某一课程名 NAME，你自行选择）。
*/

select s.SNO, s.DEGREE
from score s
join course c on c.CNO = s.CNO
where c.NAME = 'DB_Design'
order by s.DEGREE desc;

/*markdown
27、 查询每门课的平均成绩，其中每行包含课程号、课程名和平均成绩（包括平均成绩为NULL，即该课没有成绩）。
*/

select c.CNO, c.NAME, avg(s.DEGREE) as avg_score
from course c
left join score s on s.CNO = c.CNO
group by c.CNO, c.NAME;

/*markdown
28、 查询每门课程的最高分和最低分，并计算其分数差。 其中每行包含课程号、课程名和最高分、最低分和分数差。（课程无成绩的不用包括）。
*/

select c.CNO, c.NAME, max(s.DEGREE) as h_score, min(s.DEGREE) as l_score, (max(s.DEGREE) - min(s.DEGREE)) as score_diff
from course c
join score s on s.CNO = c.CNO
group by c.CNO, c.NAME
having count(s.DEGREE) > 0; 

/*markdown
29、 查询所教过的课程中有学生考试成绩低于 72 分的教师的工号和姓名（去掉重复行）。
*/

select distinct t.TNO, t.NAME
from teacher t
join course c on t.TNO = c.TNO
join score s on s.CNO = c.CNO
where s.DEGREE < 72

/*markdown
30、 查询选修了 2 门课程及以上的学生的学号、姓名。
*/

select stu.SNO, stu.NAME
from student stu
join score sc on sc.SNO = stu.SNO
group by stu.SNO, stu.NAME
having count(distinct sc.CNO) >= 2;

/*markdown
31、 查询student 表中各个学生姓名与相应的平均成绩（没有选课的学生平均成绩为 NULL）。
*/

select stu.NAME, avg(sc.DEGREE) as avg_score
from student stu
join score sc on sc.SNO = stu.SNO
group by stu.NAME;

/*markdown
32、查询每个系的学生人数和每个系的平均分， 其中每行包含系号、 系的人数和平均成绩。这里平均成绩是指每个学生的所有课程的平均成绩计算后， 与同一个系的其他同学再次计算平均值。
*/

select stu.DEPART, count(distinct stu.SNO) as num_stu, avg(avg_score) as avg_dept_score
from student stu
left join(
    select s.SNO, avg(S.DEGREE) AS avg_score
    from score s
    group by s.SNO
)as avg_dept_score 
on stu.SNO = avg_dept_score.SNO
group by stu.DEPART;

/*markdown
33、 查询所有未选修 Data_Mining 课程的学生姓名（去掉重复行）。
*/

select distinct student.NAME
from student
where student.sno not in(
    select distinct score.sno
    from score
    where score.cno = (
        select course.cno
        from course
        where course.name = 'Data_Mining'
    )
);

/*markdown
34、 查询各个课程的课程名及选该课的学生的平均年龄。（包括没有人选的课）
*/

select course.name, avg(2023 - year(student.birthday)) as avg_age
from course
left join score on course.cno = score.cno
left join student on student.sno = score.sno
group by course.name;

/*markdown
35、 查询选修了课程名中包含”Computer”课程的学生的学号和姓名。
*/

select student.sno, student.name
from student
where student.sno in (
    select score.sno
    from score
    where score.cno =(
        select course.cno
        from course
        where course.name like '%computer%'
    )
);

/*markdown
36、 查询成绩比该课程平均成绩高12分以上的同学的成绩表，即包含SNO、CNO、DEGREE。
*/

select score.sno, score.cno, score.DEGREE
from score
inner join (
    select cno, avg(degree) as avg_degree
    from score
    group by cno
) as avgDegree on avgDegree.cno = score.cno
where score.degree > avgDegree.avg_degree + 12;

/*markdown
## 视图
*/

/*markdown
37、建立女学生的学生视图（db_female_student），属性与 student 表一样，并要求对该视图进行修改和插入操作时仍需保证该视图只有女学生。
*/

drop view if exists db_female_student;

create view db_female_student as
select *
from student
where gender = 'female'
with check option;
select * from db_female_student;

/*markdown
38、将女学生视图（db_female_student）中学号为“PB210000016”的学生姓名改为{你的姓名（英文首字母）}。
*/

update db_female_student
set name = 'JHL'
where sno = 'PB210000016';
select * from db_female_student;

/*markdown
39、在女学生视图（db_female_student）中找出年龄小于 21 岁的学生，包含 SNO、NAME。
*/

select sno, name
from db_female_student
where 2023 - year(birthday) < 21;

/*markdown
40、向 student 表中插入一名“学号 SA210110021，姓名 QXY，性别女，生日 1997/7/27，12系”的学生。然后查询视图 db_female_student 的所有学生，验证其是否更新。
*/

select *
from db_female_student;

insert into student(sno, name, gender, birthday, depart)
value ('SA210110021', 'QXY', 'Female', '1997/7/27', '12');

select *
from db_female_student;

/*markdown
41、向视图 db_female_student 中插入一名“学号 SA210110023，姓名 DPC，性别男，生日1997/4/27，11 系”的学生，观察到了什么现象？
*/

insert into db_female_student(sno, name, gender, birthday, depart)
value ('SA210110023', 'DPC', 'Male', '1997/4/27', '11');

/*markdown
42、删除视图 db_female_student。
*/

drop view if exists db_female_student；

/*markdown
## 触发器
*/

/*markdown
43、创建关系表：teacher_salary(TNO, SAL)，其中 TNO 是教师工号（主键），SAL 是教师工资（类型 float）。
*/

drop table if exists teacher_salary;

create table if not exists teacher_salary(
    tno char(8) primary key,
    sal float
);

/*markdown
44、定义一个 BEFORE 行级触发器，为关系表 teacher_salary 定义完整性规则：“表中出现的工号必须也出现在 teacher 表中，否则报错”。注：该规则实际上就是外键约束；MySQL 中可使用 SIGNAL 抛出错误；需要为 INSERT 和 UPDATE 分别定义触发器。请展示出成功创建触发器和测试抛出错误信息的截图。
*/

create trigger if not exists before_teacher_salary_insert
before insert on teacher_salary
for each row
begin
    declare tno_count INT;
    select count(*) into tno_count from teacher where tno = new.tno;
    if (tno_count = 0) THEN
        SIGNAL SQLSTATE '45000' set MESSAGE_TEXT = 'insert failed: TNO does not exist in teacher table';
    end if;
end;

create trigger if not exists before_teacher_salary_update
before update on teacher_salary
for each row
begin
    declare tno_count INT;
    select count(*) into tno_count from teacher where tno = new.tno;
    if (tno_count = 0) THEN
        SIGNAL SQLSTATE '45001' set MESSAGE_TEXT = 'update failed: TNO does not exist in teacher table';
    end if;
end;


insert into teacher_salary (tno, sal)
value ('TA11', 1000);

/*markdown
45、 定义一个 BEFORE 行级触发器，为关系表 teacher_salary 定义完整性规则：“Instructor/Associate Professor/Professor 的工资不能低于 4000/5000/6000，如果低于，则改为 4000/5000/6000”。注：需要为 INSERT 和 UPDATE 分别定义触发器。并检验触发器是否工作：为 teacher_salary 构造 INSERT 和 UPDATE 语句并激活所定义过的触发器，将过程截图展示。
*/

create trigger before_teacher_salary_insert_sal
before insert on teacher_salary
for each row
begin
    declare posit varchar(30);
    select position into posit from teacher where tno = new.tno;
    if (posit = 'instructor' and new.sal < 4000) then 
        set new.sal = 4000;
    elseif (posit = 'Associate Professor' and new.sal < 5000) then 
        set new.sal = 5000;
    elseif (posit = 'Professor' and new.sal < 6000) then 
        set new.sal = 6000;
    end if;
end;

create trigger before_teacher_salary_update_sal
before update on teacher_salary
for each row
begin
    declare posit varchar(30);
    select position into posit from teacher where tno = new.tno;
    if (posit = 'instructor' and new.sal < 4000) then 
        set new.sal = 4000;
    elseif (posit = 'Associate Professor' and new.sal < 5000) then 
        set new.sal = 5000;
    elseif (posit = 'Professor' and new.sal < 6000) then 
        set new.sal = 6000;
    end if;
end;

insert into teacher_salary (tno, sal)
value ('TA90021', 100);
select * from teacher_salary;

update teacher_salary
set sal = 100
where TNO = 'TA90021';
select * from teacher_salary;

/*markdown
46、删除刚刚创建的所有触发器。
*/

drop trigger if exists before_teacher_salary_insert;
drop trigger if exists before_teacher_salary_update;
drop trigger if exists before_teacher_salary_insert_sal;
drop trigger if exists before_teacher_salary_update_sal;

/*markdown
## 空值
*/

/*markdown
47、将 score 表中的 Data_Mining 课程成绩设为空值，然后在 score 表查询学生学号和分数，并按分数升序展示。观察 NULL 在 MySQL 中的大小是怎样的？
*/

update score
set degree = null
where CNO = (
    select cno
    from course
    where NAME = 'data_mining'
);

select sno, degree
from score
order by degree asc;

/*markdown
## 开放题
*/

/*markdown
48、查询选修了两门及以上课程的学生中，选课平均成绩最高的前三名学生的学号、姓名和平均成绩。
*/

select student.sno, student.NAME, avg(score.degree) as avg_score
from student
join score on student.sno = score.sno
where student.sno in (
    select sno
    from score
    group by sno
    having count(*) >= 2
)
group by student.sno
order by avg_score desc
limit 3;

/*markdown
49、查询每个职位给的平均成绩
*/

select teacher.position, avg(score.degree) as avg
from teacher
join course on teacher.tno = course.tno
join score on score.cno = course.cno
group by teacher.position
order by avg desc;

/*markdown
50、查询每个系的男女比，并降序排列
*/

SELECT DEPART, 
    SUM(CASE WHEN GENDER = 'male' THEN 1 ELSE 0 END) AS MALE_COUNT, 
    SUM(CASE WHEN GENDER = 'female' THEN 1 ELSE 0 END) AS FEMALE_COUNT, 
    ROUND(SUM(CASE WHEN GENDER = 'male' THEN 1 ELSE 0 END) / SUM(CASE WHEN GENDER = 'female' THEN 1 ELSE 0 END), 2) AS RATIO
FROM student 
GROUP BY DEPART
ORDER BY RATIO IS NULL DESC, RATIO DESC;