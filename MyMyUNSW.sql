-- comp9311 23T3 Project 1

-- Q1:
create or replace view Q1(course_code)
as
SELECT code AS course_code
FROM Subjects
WHERE code LIKE 'HIST3%';
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q2:
create or replace view Q2(course_id)
as
SELECT ce.course AS course_id
FROM course_enrolments ce
JOIN students s ON ce.student = s.id
WHERE s.stype = 'local'
GROUP BY ce.course
HAVING COUNT(ce.student) > 400;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q3:
create or replace view Q3(course_id)
as
SELECT c.id AS course_id
FROM courses c
JOIN classes cl ON c.id = cl.course
JOIN class_types ct ON cl.ctype = ct.id
JOIN rooms r ON cl.room = r.id
WHERE ct.name = 'Lecture'
GROUP BY c.id
HAVING COUNT(DISTINCT r.building) = 4 AND COUNT(cl.id) = 4;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q4:
create or replace view Q4(unsw_id)
as
CREATE OR REPLACE VIEW Q4(unsw_id) AS
SELECT DISTINCT p.unswid
FROM People p
JOIN students st ON p.id = st.id
JOIN course_enrolments ce ON st.id = ce.student
JOIN courses c ON ce.course = c.id
JOIN semesters s ON c.semester = s.id
WHERE
    s.year = 2011
    AND s.term = 'X1'
    AND ce.grade = 'FL'
    AND st.id NOT IN (
        SELECT st.id
        FROM students st
        JOIN course_enrolments ce ON st.id = ce.student
        JOIN courses c ON ce.course = c.id
        JOIN semesters s ON c.semester = s.id
        WHERE (s.year <> 2011 OR s.term <> 'X1')
          AND ce.grade = 'FL'
    );
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q5:
CREATE OR REPLACE VIEW Q5(course_code) AS
WITH FacultyFailedCounts AS (
    SELECT o.id AS orgunit_id, s.code AS course_code, COUNT(*) AS failed_count
    FROM courses c
    JOIN course_enrolments ce ON c.id = ce.course
    JOIN subjects s ON c.subject = s.id
    JOIN orgunits o ON s.offeredby = o.id
    JOIN orgunit_types ot ON o.utype = ot.id
    JOIN semesters sem ON c.semester = sem.id
    WHERE ot.name = 'Faculty'
      AND sem.year = 2010
      AND ce.grade = 'FL'
    GROUP BY o.id, s.code, c.id
)
SELECT course_code
FROM FacultyFailedCounts
WHERE (orgunit_id, failed_count) IN (
    SELECT orgunit_id, MAX(failed_count) FROM FacultyFailedCounts GROUP BY orgunit_id
);
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q6:
create or replace view Q6(course_code, lecturer_name)
as
WITH CourseAverage AS (
    SELECT 
        s.code AS course_code, 
        p.name AS lecturer_name,
        c.semester,
        AVG(e.mark) AS avg_mark,
        RANK() OVER (PARTITION BY s.code ORDER BY AVG(e.mark) DESC) AS rank_avg_mark
    FROM Subjects s
    JOIN Courses c ON s.id = c.subject
    JOIN Course_staff cs ON c.id = cs.course
    JOIN People p ON cs.staff = p.id
    JOIN Staff_roles sr ON cs.role = sr.id
    LEFT JOIN Course_enrolments e ON c.id = e.course
    WHERE sr.name = 'Course Lecturer' AND s.code LIKE 'COMP%' AND e.mark IS NOT NULL
    GROUP BY s.code, p.name, c.semester
)

SELECT 
    ca.course_code, 
    ca.lecturer_name
FROM CourseAverage ca
WHERE ca.rank_avg_mark = 1;

--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q7:
create or replace view Q7(semester_id)
as
WITH FullTimeStudents AS (
    SELECT pe.semester, pe.student
    FROM program_enrolments pe
    JOIN programs p ON pe.program = p.id
    JOIN courses c ON c.semester = pe.semester
    JOIN course_enrolments ce ON ce.course = c.id AND ce.student = pe.student
    GROUP BY pe.semester, pe.student
    HAVING COUNT(DISTINCT c.id) >= 4
),

EngineeringStudents AS (
    SELECT s.id AS semester_id, COUNT(DISTINCT fts.student) AS eng_student_count
    FROM FullTimeStudents fts
    JOIN semesters s ON s.id = fts.semester
    JOIN program_enrolments pe ON pe.semester = s.id AND pe.student = fts.student
    JOIN programs p ON pe.program = p.id
    JOIN orgunits o ON p.offeredby = o.id
    WHERE o.longname = 'Faculty of Engineering'
    GROUP BY s.id
),

MechanicalStudents AS (
    SELECT s.id AS semester_id, COUNT(DISTINCT fts.student) AS mech_student_count
    FROM FullTimeStudents fts
    JOIN semesters s ON s.id = fts.semester
    JOIN program_enrolments pe ON pe.semester = s.id AND pe.student = fts.student
    JOIN programs p ON pe.program = p.id
    JOIN orgunits o ON p.offeredby = o.id
    WHERE o.longname = 'School of Mechanical and Manufacturing Engineering'
    GROUP BY s.id
)

SELECT e.semester_id
FROM EngineeringStudents e
LEFT JOIN MechanicalStudents m ON e.semester_id = m.semester_id
WHERE COALESCE(m.mech_student_count, 0) < e.eng_student_count;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q8:
create or replace view Q8(unsw_id)
as
WITH BachelorStream AS (
    SELECT
        pe.unswid AS unsw_id,
        AVG(ce.mark) AS bachelor_avg,
        COALESCE(se.stream, null) AS bachelor_stream
    FROM
        people pe
    JOIN
        program_enrolments proen ON pe.id = proen.student
    JOIN
        program_degrees pd ON proen.program = pd.program
    JOIN
        courses c ON proen.semester = c.semester
    JOIN
        course_enrolments ce ON c.id = ce.course AND proen.student = ce.student
    FULL JOIN
        stream_enrolments se ON proen.id = se.partof
    WHERE
        pd.name ILIKE '%Bachelor%'
    AND
        ce.mark IS NOT NULL
    GROUP BY
        pe.unswid, COALESCE(se.stream, null)
),
MasterStream AS (
    SELECT
        pe.unswid AS unsw_id,
        AVG(ce.mark) AS master_avg,
        COALESCE(se.stream, null) AS master_stream
    FROM
        people pe
    JOIN
        program_enrolments proen ON pe.id =  proen.student
    JOIN
        program_degrees pd ON proen.program = pd.program
    JOIN
        courses c ON proen.semester = c.semester
    JOIN
        course_enrolments ce ON c.id = ce.course AND proen.student = ce.student
    FULL JOIN
        stream_enrolments se ON proen.id = se.partof
    WHERE
        pd.name ILIKE '%Master%'
    AND
        ce.mark IS NOT NULL
    GROUP BY
        pe.unswid, COALESCE(se.stream, null)
)
SELECT DISTINCT ON (B.unsw_id)
    B.unsw_id AS unsw_id
FROM
    BachelorStream B
JOIN
    MasterStream M ON B.unsw_id = M.unsw_id
WHERE
    NOT (M.master_stream IS NULL AND B.bachelor_stream IS NULL)
    AND M.master_avg > B.bachelor_avg
    AND (
        (
        M.master_stream IS NULL
        AND EXISTS (
            SELECT 1
            FROM MasterStream M2
            WHERE M2.unsw_id = B.unsw_id
            AND M2.master_stream = B.bachelor_stream
        )
    )
    OR
    (
        M.master_stream IS NOT NULL
        AND B.bachelor_stream IS NOT NULL
        AND M.master_stream = B.bachelor_stream
    )
    );
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q9:
create or replace view Q9(lab_id, room_id)
as
SELECT c.id AS lab_id, r.id AS room_id
FROM classes c
JOIN courses co ON c.course = co.id
JOIN subjects s ON co.subject = s.id
JOIN class_types ct ON c.ctype = ct.id
JOIN semesters se ON co.semester = se.id
JOIN rooms r ON c.room = r.id
LEFT JOIN (
    SELECT rf.room, f.description
    FROM room_facilities rf
    JOIN facilities f ON rf.facility = f.id
    WHERE f.description ILIKE '%Slide projector%' 
    OR f.description ILIKE '%Laptop connection facilities%'
) AS unwanted_facilities ON r.id = unwanted_facilities.room
WHERE se.year = 2007
AND s.code ILIKE 'GEOS____'
AND ct.unswid = 'LAB'
AND unwanted_facilities.description IS NULL;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q10
create or replace view Q10(course_id, hd_rate)
as
CREATE OR REPLACE VIEW Q10(course_id, hd_rate) AS
WITH ValidMarks AS (
    SELECT course, COUNT(*) AS valid_students
    FROM course_enrolments
    WHERE mark IS NOT NULL
    GROUP BY course
),
HDStudents AS (
    SELECT course, COUNT(*) AS hd_students
    FROM course_enrolments
    WHERE mark >= 85
    GROUP BY course
)
SELECT c.id AS course_id, 
       COALESCE(ROUND(CAST(hd_students AS NUMERIC) / CAST(valid_students AS NUMERIC), 4), 0) AS hd_rate
FROM courses c
JOIN course_staff cs ON c.id = cs.course
JOIN staff_roles sr ON cs.role = sr.id
JOIN affiliations a ON cs.staff = a.staff
JOIN orgunits o ON a.orgunit = o.id
LEFT JOIN ValidMarks vm ON c.id = vm.course
LEFT JOIN HDStudents hd ON c.id = hd.course
WHERE sr.name = 'Course Convenor'
AND EXISTS (
    SELECT 1 FROM affiliations af
    JOIN staff_roles srf ON af.role = srf.id
    WHERE srf.name = 'Research Fellow' AND af.staff = cs.staff AND o.longname = 'School of Chemical Engineering'
)
AND COALESCE(ROUND(CAST(hd_students AS NUMERIC) / CAST(valid_students AS NUMERIC), 4), 0) > 0;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q11
create or replace view Q11(unsw_id)
as
CREATE VIEW Q11 AS
WITH EligibleForHighUOC AS (
    SELECT 
        ce.student, 
        pe.program,
        SUM(s.uoc) AS total_high_uoc,
        AVG(ce.mark) AS avg_high_mark
    FROM courses c
    JOIN subjects s ON c.subject = s.id
    JOIN course_enrolments ce ON ce.course = c.id
    JOIN program_enrolments pe ON ce.student = pe.student AND c.semester = pe.semester
    WHERE (s.code LIKE 'COMP4%' OR s.code LIKE 'COMP6%' OR s.code LIKE 'COMP8%' OR s.code LIKE 'COMP9%')
      AND ce.mark >= 50
      AND EXISTS (SELECT 1 FROM stream_enrolments se WHERE se.partof = pe.id)
    GROUP BY ce.student, pe.program
    HAVING SUM(s.uoc) > 24 AND AVG(ce.mark) > 80
),

EligibleForLowUOC AS (
    SELECT 
        ce.student, 
        pe.program,
        SUM(s.uoc) AS total_low_uoc
    FROM courses c
    JOIN subjects s ON c.subject = s.id
    JOIN course_enrolments ce ON ce.course = c.id
    JOIN program_enrolments pe ON ce.student = pe.student AND c.semester = pe.semester
    WHERE s.code LIKE 'COMP%'
      AND s.code NOT LIKE 'COMP4%'
      AND s.code NOT LIKE 'COMP6%'
      AND s.code NOT LIKE 'COMP8%'
      AND s.code NOT LIKE 'COMP9%'
      AND ce.mark >= 50
    GROUP BY ce.student, pe.program
    HAVING SUM(s.uoc) > 60
)

SELECT 
    p.unswid
FROM students st
JOIN people p ON st.id = p.id
JOIN EligibleForLowUOC lluoc ON st.id = lluoc.student
JOIN EligibleForHighUOC hluoc ON st.id = hluoc.student AND lluoc.program = hluoc.program
JOIN programs prog ON lluoc.program = prog.id
JOIN orgunits o ON prog.offeredby = o.id
WHERE o.longname = 'School of Computer Science and Engineering'
ORDER BY hluoc.avg_high_mark DESC
LIMIT 10;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q12
CREATE OR REPLACE FUNCTION Q12(course_id INTEGER, i INTEGER) RETURNS SETOF TEXT AS $$
DECLARE
    rnk INT;
BEGIN
    RETURN QUERY
    WITH RankedMarks AS (
        SELECT student, 
               mark,
               RANK() OVER (ORDER BY mark DESC) AS rank
        FROM course_enrolments
        WHERE course = course_id
    )
    SELECT CAST(student AS TEXT)
    FROM RankedMarks
    WHERE rank = i;
END;
--... SQL statements, possibly using other views/functions defined by you ...
$$ LANGUAGE plpgsql;