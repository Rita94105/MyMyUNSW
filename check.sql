-- COMP9311 23T3 Project Check
--
-- MyMyUNSW Check

SET client_min_messages TO WARNING;

create or replace function
	proj1_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

-- proj1_check_result:
-- * determines appropriate message, based on count of
--   excess and missing tuples in user output vs expected output

create or replace function
	proj1_check_result(_res text,nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return _res || ' correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return _res || ' too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return _res || ' missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return _res || ' incorrect result tuples';
	end if;
end;
$$ language plpgsql;

-- proj1_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not proj1_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not proj1_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
				 'from (('||_query||') except '||
				 '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
					'from ((select * from '||_res||') '||
					'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return proj1_check_result(_res,nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

-- proj1_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

-- check_all:
-- * run all of the checks and return a table of results

drop type if exists TestingResult cascade;
create type TestingResult as (test text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	testQ text;
	result text;
	out TestingResult;
	tests text[] := array['q1', 'q2', 'q3', 'q4', 'q5','q6','q7','q8','q9',
	'q10','q11',
	'q12a','q12b','q12c','q12d','q12e'];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--
-- Check functions for specific test-cases in Project 1
--

create or replace function check_q1() returns text
as $chk$
select proj1_check('view','q1','q1_expected',
									 $$select * from q1$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select proj1_check('view','q2','q2_expected',
									 $$select * from q2$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select proj1_check('view','q3','q3_expected',
									 $$select * from q3$$)
$chk$ language sql;

create or replace function check_q4() returns text
as $chk$
select proj1_check('view','q4','q4_expected',
									 $$select * from q4$$)
$chk$ language sql;

create or replace function check_q5() returns text
as $chk$
select proj1_check('view','q5','q5_expected',
									 $$select * from q5$$)
$chk$ language sql;

create or replace function check_q6() returns text
as $chk$
select proj1_check('view','q6','q6_expected',
									 $$select * from q6$$)
$chk$ language sql;

create or replace function check_q7() returns text
as $chk$
select proj1_check('view','q7','q7_expected',
									 $$select * from q7$$)
$chk$ language sql;

create or replace function check_q8() returns text
as $chk$
select proj1_check('view','q8','q8_expected',
									 $$select * from q8$$)
$chk$ language sql;

create or replace function check_q9() returns text
as $chk$
select proj1_check('view','q9','q9_expected',
									 $$select * from q9$$)
$chk$ language sql;

create or replace function check_q10() returns text
as $chk$
select proj1_check('view','q10','q10_expected',
									 $$select * from q10$$)
$chk$ language sql;

create or replace function check_q11() returns text
as $chk$
select proj1_check('view','q11','q11_expected',
									 $$select * from q11$$)
$chk$ language sql;

-- Q12
create or replace function check_q12a() returns text
as $chk$
select proj1_check('function','q12','q12a_expected',
									 $$select q12(54233, 11)$$)
$chk$ language sql;

create or replace function check_q12b() returns text
as $chk$
select proj1_check('function','q12','q12b_expected',
									 $$select q12(63045, 5)$$)
$chk$ language sql;

create or replace function check_q12c() returns text
as $chk$
select proj1_check('function','q12','q12c_expected',
									 $$select q12(49477, 20)$$)
$chk$ language sql;

create or replace function check_q12d() returns text
as $chk$
select proj1_check('function','q12','q12d_expected',
									 $$select q12(48819, 442)$$)
$chk$ language sql;

create or replace function check_q12e() returns text
as $chk$
select proj1_check('function','q12','q12e_expected',
									 $$select q12(61087, 71)$$)
$chk$ language sql;

--
-- Tables of expected results for test cases
--

drop table if exists q1_expected;
create table q1_expected (
	course_code character(8)
);

drop table if exists q2_expected;
create table q2_expected (
	course_id integer
);

drop table if exists q3_expected;
create table q3_expected (
	course_id integer
);

drop table if exists q4_expected;
create table q4_expected (
	unsw_id integer
);

drop table if exists q5_expected;
create table q5_expected (
	course_code character(8)
);

drop table if exists q6_expected;
create table q6_expected (
	course_code character(8), lecturer longname
);

drop table if exists q7_expected;
create table q7_expected (
	semester_id integer
);

drop table if exists q8_expected;
create table q8_expected (
	unsw_id integer
);

drop table if exists q9_expected;
create table q9_expected (
	lab_id integer, room_id integer
);

drop table if exists q10_expected;
create table q10_expected (
	course_id integer, hd_rate numeric
);

drop table if exists q11_expected;
create table q11_expected (
	unsw_id integer
);

drop table if exists q12a_expected;
create table q12a_expected (
	q12 text
);

drop table if exists q12b_expected;
create table q12b_expected (
	q12 text
);

drop table if exists q12c_expected;
create table q12c_expected (
	q12 text
);

drop table if exists q12d_expected;
create table q12d_expected (
	q12 text
);

drop table if exists q12e_expected;
create table q12e_expected (
	q12 text
);
-- ( )+\|+( )+

COPY q1_expected (course_code) FROM stdin;
HIST3916
HIST3101
HIST3116
HIST3103
HIST3108
HIST3106
HIST3110
HIST3918
HIST3001
HIST3002
HIST3013
HIST3011
HIST3012
HIST3900
HIST3911
HIST3912
HIST3901
HIST3902
HIST3904
HIST3500
HIST3100
HIST3914
HIST3102
HIST3907
HIST3117
HIST3905
HIST3109
HIST3111
HIST3917
\.

COPY q2_expected (course_id) FROM stdin;
55833
48819
47884
62762
61406
40958
48035
59046
49475
54474
56391
52145
49019
41693
47425
62020
47105
66061
\.

COPY q3_expected (course_id) FROM stdin;
1253
2158
3192
6008
6543
6557
7434
10790
11669
11992
11993
12097
12443
13724
14786
15049
16326
16474
18594
19215
19661
20419
20554
22455
22970
23252
27951
27955
28157
33972
34528
37966
40423
40427
41252
47223
47820
47889
50560
51422
54851
55836
55907
55913
56181
57281
58374
62101
69710
71160
72938
\.

COPY q4_expected (unsw_id) FROM stdin;
3274955
3234436
3220930
3200738
3335117
3257809
3375230
3307699
3331132
3336870
3304344
3356203
3343131
\.

COPY q5_expected (course_code) FROM stdin;
MDIA5001
BENV2135
BENV7712
COFA0210
ENGG1000
GENL1062
MFAC1526
\.

COPY q6_expected (course_code, lecturer) FROM stdin;
COMP1091	Richard Buckland
COMP1400	Malcolm Ryan
COMP1911	Angela Finlayson
COMP1911	Achim Hoffmann
COMP1917	Richard Buckland
COMP1921	Nandan Parameswaran
COMP1927	Albert Nymeyer
COMP2011	Alan Blair
COMP2041	Andrew Taylor
COMP2911	Albert Nymeyer
COMP3111	Albert Nymeyer
COMP3171	Jingling Xue
COMP3211	Sri Parameswaran
COMP3222	Hui Guo
COMP3231	Kevin Elphinstone
COMP3311	Jessica Wong
COMP3411	Claude Sammut
COMP3511	Nadine Marcus
COMP3711	Pradeep Ray
COMP3891	Leonid Ryzhyk
COMP4001	John Potter
COMP4161	June Andronick
COMP4314	Wei Wang
COMP4314	Jessica Wong
COMP4314	Jian Zhang
COMP4418	Maurice Pagnucco
COMP4418	Michael Thielscher
COMP4920	Wayne Wobcke
COMP9008	Albert Nymeyer
COMP9021	Jahan Hassan
COMP9024	Ronald Van der Meyden
COMP9041	Andrew Taylor
COMP9171	Jingling Xue
COMP9201	Kevin Elphinstone
COMP9211	Sri Parameswaran
COMP9222	Hui Guo
COMP9242	Gernot Heiser
COMP9283	Leonid Ryzhyk
COMP9311	Ying Zhang
COMP9314	Wei Wang
COMP9314	Jessica Wong
COMP9314	Jian Zhang
COMP9321	Hye-Young Paik
COMP9322	Boualem Benatallah
COMP9414	Wayne Wobcke
COMP9444	Achim Hoffmann
COMP9511	Arthur Ramer
COMP9814	Wayne Wobcke
COMP9844	Achim Hoffmann
\.

COPY q7_expected (semester_id) FROM stdin;
160
162
164
165
167
168
\.

COPY q8_expected (unsw_id) FROM stdin;
3038200
3067909
3109384
3119572
3145186
3157793
3158049
3208494
3208889
3211322
3221611
3241560
3245000
3258960
3319396
3334357
3369985
3383829
3395395
3398378
3429346
\.

COPY q9_expected (lab_id, room_id) FROM stdin;
49781	22
49782	22
49783	22
49784	22
49785	22
49786	22
49787	22
49788	22
49797	29
49799	29
49800	29
49803	29
49804	22
49806	22
49808	29
49809	29
49812	21
49815	17
49824	32
49825	32
49826	555
49827	555
49832	32
49833	555
49834	555
49837	21
56863	22
56864	22
56867	22
56868	22
56886	22
56887	22
56889	21
56891	22
56892	22
56895	22
56896	22
56898	22
56911	30
56914	29
56915	29
56920	21
56930	21
56937	21
\.


COPY q10_expected (course_id, hd_rate) FROM stdin;
23312	0.1429
27095	0.0769
30283	0.0909
34014	0.1200
37413	0.1250
54624	0.1304
57846	0.2439
57847	0.2000
61556	0.1200
64828	0.1750
66220	0.0625
\.

COPY q11_expected (unsw_id) FROM stdin;
3232152
3144015
3278476
3219452
3209070
3183655
3230042
3131729
3159514
3272701
\.

COPY q12a_expected (q12) FROM stdin;
1192096
1192191
1192769
\.

COPY q12b_expected (q12) FROM stdin;
1171242
1157839
1172717
1170695
\.


COPY q12c_expected (q12) FROM stdin;
1158657
1157020
1153047
1143077
1155933
\.


COPY q12d_expected (q12) FROM stdin;
1170809
1178603
1172628
1172632
1178076
1167369
1176008
1173045
1175177
1170045
1175984
1174592
1174563
1174485
1176258
1172426
1171406
\.


COPY q12e_expected (q12) FROM stdin;
1204923
1208549
1193626
1189107
1211069
1204882
\.


