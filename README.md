# MyMyUNSW
Implementing SQL queries and views to satisfy requests for information in a moderately large relational schema (MyMyUNSW).

### Introduction

- UNSW has spent a considerable amount of money ($80M+) on the MyUNSW/NSS system, 
and it handles much of the educational administration plausibly well.
- The MyMyUNSW database includes information that encompasses the functionality of NSS, 
the UNSW Online Handbook, and the CATS (room allocation) database. 
- The MyMyUNSW data model, schema and database are described in a separate document.

## Tasks

### Question 1
Define a SQL view Q1(course_code)that gives the code of subjects that is equivalent to level 3 HIST courses (i.e., with a course code of the format HIST3***)
- course_code should be taken from Subjects.code field.

### Question 2
Define a SQL view Q2(course_id) that gives the distinct id of the courses that have over 400 local students enrolled.
- course_id should be taken from Courses.id field;
- local students refer to students whose Students.stype is ‘local’.

### Question 3
Define a SQL view Q3(course_id) that gives the distinct id of courses that only have 4 lectures, and each lecture taking place in a different building.
- course_id should be taken from Courses.id field;
- buildings refer to Rooms.building;
- Lecture refers to the class where its Class_types.name is ‘Lecture’.

### Question 4
Define a SQL view Q4(unsw_id) that gives the distinct id of students who only fail course in the semester 2011 X1.
- unsw_id should be taken from People.unswid field;
- Failing a course means that the grade a student received for a course is ‘FL’.

### Question 5
Define a SQL view Q5(course_code)that gives the code of the courses that have the highest number of students failed among all the courses offered by the same faculty in the year 2010. If there are multiple courses sharing the highest number of failed students, list all the course_code of these courses.
- course_code should be taken from Subjects.code of the corresponding subject;
- Faculties refer to the organization units where their Orgunit_types.name are ‘Faculty’;
- Failing a course means that the grade a student received for a course is ‘FL’.

### Question 6
Define a SQL view Q6(course_code, lecturer_name)that gives the code of all the COMP courses (i.e., with a course code of the format COMP****) and the name of the corresponding lecturers who taught in the semester that achieved the highest average mark compared to all other semesters with the same course code (i.e. all the courses with the same Courses.subject). If there are multiple lecturers sharing the same highest average mark for the same course_code, list all of them.
- course_code should be taken from Subjects.code field of the corresponding subject;
- lecturer_name should be taken from People.name field;
- Lecturer refers the staff whose Staff_roles.name is ‘Course Lecturer’;
- Mark refers to Course_enrolments.mark field;
- Do not consider courses without lecturers;
- When calculating the average mark, we do not count students whose mark is null.

### Question 7
Define a SQL view Q7(semester_id) that gives the id of semesters where the number of full- time students (i.e., students who enrolled in at least 4 courses within this semester) enrolled in programs offered by the Faculty of Engineering are more than those enrolled in programs offered by School of Mechanical and Manufacturing Engineering.
- semester_id should be taken from Semesters.id field;
- Faculty of Engineering refers to the organization unit where its Orgunits.longname is ‘Faculty of Engineering’;
- School of Mechanical and Manufacturing Engineering refers to the organization unit where its Orgunits.longname is ‘School of Mechanical and Manufacturing Engineering’.

### Question 8
Define SQL view Q8(unsw_id) that gives the id of students who were enrolled in the same stream in their bachelor and master degree. Additionally, their average mark in the master degree should be higher than the average mark in the bachelor degree.
- unsw_id should be taken from People.unswid field;
- Bachelor degrees refer to the programs where Program_degrees.name contains ‘Bachelor’ in a case-insensitive manner;
- Master degrees refer to the programs where Program_degrees.name contains ‘Master’ in a case-insensitive manner;
- When calculating the average mark of a program, we consider a course belong to a program if a student enrolled in this course and this program in the same semester (refers to Semestsers.id);
- When calculating the average mark, we do not consider the courses where students received a null mark.

### Question 9
Define SQL view Q9(lab_id, room_id) that gives the id of GEOS labs held in year 2007(refer to Semesters.year) and corresponding id of rooms where the rooms of these labs do not have both slide projector and laptop connection facilities at the same time.
- GEOS labs refer to the classes where the corresponding course code(Subjects.code) with the format ‘GEOS****’ and their Class_types.unswid is ‘LAB’;
- Slide projector refers to the facility where its description contains ‘Slide projector’ in a case-insensitive manner;
- Laptop connection facilities refers to the facility where its description contains ‘Laptop connection facilities’ in a case-insensitive manner;
- lab_id should be taken from Classes.id field;
• room_id should be taken from Rooms.id field.

### Question 10
Define SQL view Q10(course_id, hd_rate) that gives the id of course and the corresponding HD rate of this course.
We only consider the courses where the course convenor is a research fellow of School of Chemical Engineering.
Round hd_rate to the nearest 0.0001. (i.e., if hd_rate = 0.01 (i.e., 1%), then return 0.0100;
if hd_rate = 0.01234, then return 0.0123; if hd_rate = 0.02345, then return 0.0235).
This rounding behavior is different from the IEEE 754 specification for floating point rounding which PostgreSQL uses for float/real/double precision types. PostgreSQL only performs this type of rounding for numeric and decimal types.
- hd rate = (number of students with mark >= 85 ÷ number of students with mark);
- Only count the students with valid marks(refer to Course_enrolments.mark) that are not null.
- Course convenor refers to the staff of a course where the Staff_roles.name is ‘Course Convenor’;
- Research fellow refers to the staff of an organization where the Staff_roles.name is ‘Research Fellow’;
- To find the research fellow of a certain organization unit, you should check the Affiliations table;
- Do not include the courses that have no student enrolled;
- course_id should be taken from Courses.id;
- hd_rate should be in numeric type.

### Question 11
Define SQL view Q11(unsw_id) that gives the id of students who are eligible for scholarship. To qualify for the scholarship, a student should enroll into a program and meet these criteria within this program:
1. the program is offered by School of Computer Science and Engineering (refer to orgunits.longname);
2. Have earned over 60 UOC in non-high level COMP courses;
3. Have earned over 24 UOC in high level COMP courses with streams;
4. Their average marks of the high level COMP courses with streams must exceed 80.


From all eligible candidate students, return the top 10 students with the highest average marks in high-level COMP courses with streams.

Note:

- COMP courses refer to the course code with the format ‘COMP****’;
- High level COMP courses refer to the course code with the format ‘COMP4***’, ‘COMP6***’, ‘COMP8***’ or ‘COMP9***’;
- A student can only earn the UOC of the courses he/she pass, i.e., the mark for the course (refers to Course_enrolments.mark) should be no less than 50.
- If a student has enrolled into several different programs, you need to calculate the UOC and the average mark separately according to different programs. A course is included in a program if this student enrolled into the course and the program in the same semester (refer to semester.id);
- In criteria c) and d), the uoc and average mark are calculated at the program level, not stream level. If a student is enrolled in different streams, “with stream” indicates that you only need to consider uoc and marks of courses taken in semesters where the student was enrolled in any stream(refer to stream_enrolments), regardless of which specific stream it was.
- If multiple students achieved the same average mark, they should be assigned with the same ranking. The Rank() function in PostgreSQL will be able to do this for you to generate the ranking column.

Example: Say a student has enrolled in Bachelor of Computer Science and Master of Computer Science.
- Scenario A
  
  He meets criteria 1. and 2. in Bachelor of Computer Science and meets criteria 1., 3. and 4. in Master of Computer Science.
  Since he does not satisfy all 4 criteria in either of the programs, he would not be considered for the scholarship.
- Scenario B
  
  He meets criteria 1., 2., 3. and 4. in Bachelor of Computer Science. 
  Then he may be considered for the scholarship, depending on whether he ranked top 10.
 
### Question 12
Define a PL/pgSQL function Q12(course_id Integer, i Integer) that takes the id of a course and an integer, and returns a set of student_id whose mark ranked ith in that course.
- course_id is taken from Courses.id field;
- student_id is taken from Students.id field;
- mark refers to Course_enrolments.mark field;
- i is a positive integer.

Each line of the output (in text type) should contain one element which is student_id.

Example: 

  - If 5 students enrolled in COMP9311 23T3 with a course id of 100, and their student ids, marks and ranks are as follows. 
  
  - If the input course id matches 100 and input parameter i=1, the returned result should have only one student_id 3. 
  
  - If i=2, the result should contain two student_ids: 2 and 5. If i=3 or i>5, then the result should not contain any row. 
  
  - You don’t need to consider any other invalid inputs.
  
  | student_id    | mark    | rank  |
  | ------------- |:-------:| -----:|
  | 1             | 70      |     4 |
  | 2             | 80      |     2 |
  | 3             | 90      |     1 |
  | 4             | 60      |     5 |
  | 5             | 80      |     2 |
