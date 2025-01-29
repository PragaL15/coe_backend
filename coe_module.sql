--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'WIN1252';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: get_faculty_requests(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_faculty_requests() RETURNS TABLE(id integer, date_submitted timestamp without time zone, papers integer, deadline timestamp without time zone, faculty_name character varying, course_code character varying, semester_code character varying, reason text, status character varying, remarks text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fr.id,
        fr.createdat AS date_submitted,
        fr.total_allocated_papers AS papers,
        fr.updatedat + (fr.deadline_left || ' days')::INTERVAL AS deadline,
        ft.faculty_name,
        'CS101'::VARCHAR AS course_code, -- Replace with actual course_code logic
        fr.sem_code AS semester_code,
        fr.remarks AS reason,
        CASE 
            WHEN fr.approval_status = 1 THEN 'Approved'
            WHEN fr.approval_status = 2 THEN 'Rejected'
            ELSE 'Initiated'
        END AS status,
        fr.remarks
    FROM 
        faculty_request fr
    INNER JOIN 
        faculty_table ft ON fr.faculty_id = ft.faculty_id;
END;
$$;


ALTER FUNCTION public.get_faculty_requests() OWNER TO postgres;

--
-- Name: insert_faculty_request(integer, integer, integer, integer, text, integer, integer, integer, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_faculty_request(faculty_id integer, total_allocated_papers integer, papers_left integer, course_id integer, remarks text, approval_status integer DEFAULT 0, status integer DEFAULT 0, deadline_left integer DEFAULT 0, sem_code character varying DEFAULT ''::character varying, sem_academic_year character varying DEFAULT ''::character varying, year integer DEFAULT 0) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO faculty_request (
        faculty_id,
        total_allocated_papers,
        papers_left,
        course_id,
        remarks,
        approval_status,
        status,
        deadline_left,
        sem_code,
        sem_academic_year,
        year,
        createdat,
        updatedat
    )
    VALUES (
        faculty_id,
        total_allocated_papers,
        papers_left,
        course_id,
        remarks,
        approval_status,
        status,
        deadline_left,
        sem_code,
        sem_academic_year,
        year,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );
END;
$$;


ALTER FUNCTION public.insert_faculty_request(faculty_id integer, total_allocated_papers integer, papers_left integer, course_id integer, remarks text, approval_status integer, status integer, deadline_left integer, sem_code character varying, sem_academic_year character varying, year integer) OWNER TO postgres;

--
-- Name: set_created_at_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_created_at_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.createdAt = CURRENT_TIMESTAMP;  -- Set createdAt to current timestamp
        NEW.updatedAt = CURRENT_TIMESTAMP;  -- Set updatedAt to current timestamp
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.updatedAt = CURRENT_TIMESTAMP;  -- Update updatedAt to current timestamp
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_created_at_updated_at() OWNER TO postgres;

--
-- Name: update_paper_corrected(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_paper_corrected() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if paper_corrected_today is greater than 0
    IF NEW.paper_corrected_today > 0 THEN
        -- Update the paper_corrected column in faculty_all_records
        UPDATE faculty_all_records
        SET paper_corrected = paper_corrected + NEW.paper_corrected_today
        WHERE faculty_id = NEW.faculty_id AND paper_id = NEW.paper_id;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_paper_corrected() OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updatedAt = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

--
-- Name: update_updatedat_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updatedat_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updatedAt = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updatedat_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academic_year_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.academic_year_table (
    id integer NOT NULL,
    academic_year character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status integer NOT NULL
);


ALTER TABLE public.academic_year_table OWNER TO postgres;

--
-- Name: academic_year_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.academic_year_table_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.academic_year_table_id_seq OWNER TO postgres;

--
-- Name: academic_year_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.academic_year_table_id_seq OWNED BY public.academic_year_table.id;


--
-- Name: bce_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bce_table (
    id integer NOT NULL,
    dept_id integer NOT NULL,
    bce_id character varying(50) NOT NULL,
    bce_name character varying(100) NOT NULL,
    status boolean DEFAULT true,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    mobile_num character varying(50),
    email character varying(50)
);


ALTER TABLE public.bce_table OWNER TO postgres;

--
-- Name: bce_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bce_table_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bce_table_id_seq OWNER TO postgres;

--
-- Name: bce_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bce_table_id_seq OWNED BY public.bce_table.id;


--
-- Name: course_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_id_seq OWNER TO postgres;

--
-- Name: course_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_table (
    course_id integer DEFAULT nextval('public.course_id_seq'::regclass) NOT NULL,
    course_code character varying(50) NOT NULL,
    course_name character varying(255) NOT NULL,
    status integer DEFAULT 1,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    sem_code character varying(50)
);


ALTER TABLE public.course_table OWNER TO postgres;

--
-- Name: daily_faculty_updates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.daily_faculty_updates (
    update_id integer NOT NULL,
    faculty_id integer NOT NULL,
    paper_id integer NOT NULL,
    paper_corrected_today integer,
    remarks text,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT daily_faculty_updates_paper_corrected_today_check CHECK ((paper_corrected_today >= 0))
);


ALTER TABLE public.daily_faculty_updates OWNER TO postgres;

--
-- Name: daily_faculty_updates_update_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.daily_faculty_updates_update_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.daily_faculty_updates_update_id_seq OWNER TO postgres;

--
-- Name: daily_faculty_updates_update_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.daily_faculty_updates_update_id_seq OWNED BY public.daily_faculty_updates.update_id;


--
-- Name: dept_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dept_table (
    id integer NOT NULL,
    dept_name character varying(255) NOT NULL,
    status integer DEFAULT 1,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.dept_table OWNER TO postgres;

--
-- Name: dept_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dept_table_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dept_table_id_seq OWNER TO postgres;

--
-- Name: dept_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dept_table_id_seq OWNED BY public.dept_table.id;


--
-- Name: faculty_all_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faculty_all_records (
    faculty_id integer NOT NULL,
    course_id integer NOT NULL,
    paper_allocated integer NOT NULL,
    deadline integer,
    status integer,
    bce_id character varying(50),
    sem_code text,
    dept_id integer,
    paper_corrected integer,
    paper_pending integer GENERATED ALWAYS AS ((paper_allocated - paper_corrected)) STORED,
    paper_id integer,
    CONSTRAINT chk_paper_corrected CHECK ((paper_corrected <= paper_allocated))
);


ALTER TABLE public.faculty_all_records OWNER TO postgres;

--
-- Name: faculty_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.faculty_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.faculty_id_seq OWNER TO postgres;

--
-- Name: faculty_request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faculty_request (
    id integer NOT NULL,
    faculty_id integer NOT NULL,
    papers_left integer,
    course_id integer,
    remarks text,
    approval_status integer DEFAULT 0,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deadline_left integer,
    sem_code character varying(50),
    sem_academic_year character varying(10) NOT NULL,
    reason text,
    paper_id integer,
    bce_id integer
);


ALTER TABLE public.faculty_request OWNER TO postgres;

--
-- Name: faculty_request_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.faculty_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.faculty_request_id_seq OWNER TO postgres;

--
-- Name: faculty_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.faculty_request_id_seq OWNED BY public.faculty_request.id;


--
-- Name: faculty_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.faculty_table (
    faculty_id integer DEFAULT nextval('public.faculty_id_seq'::regclass) NOT NULL,
    faculty_name character varying(255) NOT NULL,
    dept integer NOT NULL,
    status integer DEFAULT 1,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    mobile_num character varying(15) NOT NULL,
    email character varying(50),
    CONSTRAINT chk_mobile_num_format CHECK (((mobile_num)::text ~ '^\d{10}$'::text))
);


ALTER TABLE public.faculty_table OWNER TO postgres;

--
-- Name: paper_id_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paper_id_table (
    id integer NOT NULL,
    paper_id character varying(50)
);


ALTER TABLE public.paper_id_table OWNER TO postgres;

--
-- Name: paper_id_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.paper_id_table_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paper_id_table_id_seq OWNER TO postgres;

--
-- Name: paper_id_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paper_id_table_id_seq OWNED BY public.paper_id_table.id;


--
-- Name: semester_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.semester_table (
    id integer NOT NULL,
    sem_code character varying(50) NOT NULL,
    sem_academic_year character varying(10) NOT NULL,
    status integer DEFAULT 1,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.semester_table OWNER TO postgres;

--
-- Name: semester_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.semester_table_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.semester_table_id_seq OWNER TO postgres;

--
-- Name: semester_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.semester_table_id_seq OWNED BY public.semester_table.id;


--
-- Name: user_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_table (
    user_id integer NOT NULL,
    user_name character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role_id integer NOT NULL,
    status boolean DEFAULT true NOT NULL
);


ALTER TABLE public.user_table OWNER TO postgres;

--
-- Name: user_table_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_table_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_table_user_id_seq OWNER TO postgres;

--
-- Name: user_table_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_table_user_id_seq OWNED BY public.user_table.user_id;


--
-- Name: academic_year_table id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_year_table ALTER COLUMN id SET DEFAULT nextval('public.academic_year_table_id_seq'::regclass);


--
-- Name: bce_table id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bce_table ALTER COLUMN id SET DEFAULT nextval('public.bce_table_id_seq'::regclass);


--
-- Name: daily_faculty_updates update_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_faculty_updates ALTER COLUMN update_id SET DEFAULT nextval('public.daily_faculty_updates_update_id_seq'::regclass);


--
-- Name: dept_table id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dept_table ALTER COLUMN id SET DEFAULT nextval('public.dept_table_id_seq'::regclass);


--
-- Name: faculty_request id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_request ALTER COLUMN id SET DEFAULT nextval('public.faculty_request_id_seq'::regclass);


--
-- Name: paper_id_table id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paper_id_table ALTER COLUMN id SET DEFAULT nextval('public.paper_id_table_id_seq'::regclass);


--
-- Name: semester_table id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.semester_table ALTER COLUMN id SET DEFAULT nextval('public.semester_table_id_seq'::regclass);


--
-- Name: user_table user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_table ALTER COLUMN user_id SET DEFAULT nextval('public.user_table_user_id_seq'::regclass);


--
-- Data for Name: academic_year_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.academic_year_table (id, academic_year, created_at, updated_at, status) FROM stdin;
1	2023-2024	2025-01-22 20:14:19.48375	2025-01-22 20:14:19.48375	0
2	2022-2023	2025-01-22 20:14:19.48375	2025-01-22 20:14:19.48375	0
3	2021-2022	2025-01-22 20:14:19.48375	2025-01-22 20:14:19.48375	0
4	2025-2026	2025-01-25 10:39:08.616153	2025-01-25 10:39:08.616153	1
5	2024-2026	2025-01-25 14:56:18.07813	2025-01-25 14:56:18.07813	1
6	4012	2025-01-25 15:05:58.93459	2025-01-25 15:05:58.93459	1
\.


--
-- Data for Name: bce_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bce_table (id, dept_id, bce_id, bce_name, status, createdat, updatedat, mobile_num, email) FROM stdin;
6	101	BCE1001	Engineering Basics	t	2025-01-23 21:44:49.646976	2025-01-23 21:44:49.646976	\N	\N
7	102	BCE1002	Mathematics I	t	2025-01-23 21:44:49.646976	2025-01-23 21:44:49.646976	\N	\N
8	101	BCE2025	Building Construction Engineering	t	2025-01-24 23:57:15.310151	2025-01-24 23:57:15.310151	\N	\N
10	114	BCE12345	Board Chairman Example	t	2025-01-25 21:53:44.683118	2025-01-25 21:53:44.683118	9876543210	chairman@example.com
11	101	RTYU67	Gomathi	f	2025-01-25 23:08:46.823429	2025-01-25 23:08:46.823429	6543765412	gomathi@bitsathy.a.ci
\.


--
-- Data for Name: course_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course_table (course_id, course_code, course_name, status, createdat, updatedat, sem_code) FROM stdin;
102	MATH101	Mathematics Fundamentals	1	2024-12-26 11:02:25.815892	2025-01-25 09:55:44.648187	SEM101
101	CS101	Advanced Computer Science	1	2024-12-26 11:02:25.815892	2025-01-25 09:55:44.648187	SEM101
103	ENG101	Introduction to English Literature	1	2025-01-24 10:34:11.91702	2025-01-25 09:55:44.648187	SEM101
104	BIO101	Biology Basics	1	2025-01-24 10:34:11.91702	2025-01-25 09:55:44.648187	SEM101
109	CS101	Introduction to Computer Science	1	2025-01-25 00:05:51.096881	2025-01-25 09:55:44.648187	SEM101
111	CS101	Introduction to Computer Science	1	2025-01-25 09:42:55.960342	2025-01-25 09:55:44.648187	SEM101
112	MG001	Engineering math	1	2025-01-25 10:04:36.652196	2025-01-25 10:04:36.652196	SEM102
113	CD102	Theory of computing	1	2025-01-25 13:49:06.250922	2025-01-25 13:49:06.250922	SEM202
\.


--
-- Data for Name: daily_faculty_updates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daily_faculty_updates (update_id, faculty_id, paper_id, paper_corrected_today, remarks, createdat) FROM stdin;
13	3	3	20	nil	2025-01-27 01:03:26.096519
\.


--
-- Data for Name: dept_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dept_table (id, dept_name, status, createdat, updatedat) FROM stdin;
101	Department 101	1	2025-01-22 16:27:47.997933	2025-01-22 16:27:47.997933
102	Department 102	1	2025-01-22 16:27:47.997933	2025-01-22 16:27:47.997933
103	Department 103	1	2025-01-22 16:27:47.997933	2025-01-22 16:27:47.997933
104	Department 104	1	2025-01-22 16:27:47.997933	2025-01-22 16:27:47.997933
105	Department 105	1	2025-01-24 10:32:53.828519	2025-01-24 10:32:53.828519
106	Department 106	1	2025-01-24 10:32:53.828519	2025-01-24 10:32:53.828519
107	Department 107	1	2025-01-24 10:32:53.828519	2025-01-24 10:32:53.828519
2	Computer Science	1	2025-01-25 00:24:56.217741	2025-01-25 00:24:56.217741
112	Test Department	1	2025-01-25 20:53:01.585656	2025-01-25 20:53:01.585656
0	csd	1	2025-01-25 21:05:52.689722	2025-01-25 21:05:52.689722
113	Mechanical Engineering	1	2025-01-25 21:27:22.694323	2025-01-25 21:27:22.694323
114	fd	1	2025-01-25 21:27:39.550096	2025-01-25 21:27:39.550096
115	vfg	1	2025-01-25 22:36:13.052273	2025-01-25 22:36:13.052273
\.


--
-- Data for Name: faculty_all_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faculty_all_records (faculty_id, course_id, paper_allocated, deadline, status, bce_id, sem_code, dept_id, paper_corrected, paper_id) FROM stdin;
3	103	150	15	3	BCE125	CS103	12	50	3
101	101	100	5	1	BCE123	CS101	10	20	1
1	101	100	5	1	BCE123	CS101	10	20	1
102	101	100	5	1	BCE123	CS101	10	20	1
\.


--
-- Data for Name: faculty_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faculty_request (id, faculty_id, papers_left, course_id, remarks, approval_status, createdat, updatedat, deadline_left, sem_code, sem_academic_year, reason, paper_id, bce_id) FROM stdin;
1	101	10	101	Approved and ready for next step	-1	2025-01-23 14:34:54.355981	2025-01-23 15:36:14.787646	7	Fall2024	2024-2025	oiug	\N	\N
20	1	10	101	Remark about the request	1	2025-01-26 23:30:10.920982	2025-01-27 01:08:16.218677	5	SEM001	2025		1	\N
2	102	15	102	Final review pending	-1	2025-01-23 14:34:54.355981	2025-01-27 01:31:24.97104	10	Spring2025	2024-2025	nil	\N	\N
\.


--
-- Data for Name: faculty_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faculty_table (faculty_id, faculty_name, dept, status, createdat, updatedat, mobile_num, email) FROM stdin;
3	Alice Brown	103	1	2025-01-22 16:28:03.411904	2025-01-23 15:20:23.770292	9876543212	\N
\.


--
-- Data for Name: paper_id_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paper_id_table (id, paper_id) FROM stdin;
1	it104
2	it105
3	it106
\.


--
-- Data for Name: semester_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.semester_table (id, sem_code, sem_academic_year, status, createdat, updatedat) FROM stdin;
1	SEM101	2023-2024	1	2025-01-22 17:52:33.36036	2025-01-22 17:52:33.36036
2	SEM102	2023-2024	1	2025-01-22 17:52:33.36036	2025-01-22 17:52:33.36036
3	SEM201	2024-2025	1	2025-01-22 17:52:33.36036	2025-01-22 17:52:33.36036
4	SEM202	2024-2025	1	2025-01-22 17:52:33.36036	2025-01-22 17:52:33.36036
5	CD2024	2024-2025	1	2025-01-25 00:43:09.210124	2025-01-25 00:43:09.210124
7	SEM222	2024-2025	1	2025-01-25 15:41:50.322458	2025-01-25 15:41:50.322458
9	SEM322	2024-2025	1	2025-01-25 16:02:49.603156	2025-01-25 16:02:49.603156
10	SEM203	2024-2026	1	2025-01-25 16:07:32.259186	2025-01-25 16:07:32.259186
\.


--
-- Data for Name: user_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_table (user_id, user_name, password, role_id, status) FROM stdin;
1	john_doe	password123	1	t
2	jane_smith	password456	2	t
3	alex_jones	password789	3	f
\.


--
-- Name: academic_year_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.academic_year_table_id_seq', 6, true);


--
-- Name: bce_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bce_table_id_seq', 11, true);


--
-- Name: course_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_id_seq', 113, true);


--
-- Name: daily_faculty_updates_update_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.daily_faculty_updates_update_id_seq', 13, true);


--
-- Name: dept_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dept_table_id_seq', 115, true);


--
-- Name: faculty_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.faculty_id_seq', 235, true);


--
-- Name: faculty_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.faculty_request_id_seq', 20, true);


--
-- Name: paper_id_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.paper_id_table_id_seq', 3, true);


--
-- Name: semester_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.semester_table_id_seq', 10, true);


--
-- Name: user_table_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_table_user_id_seq', 1, false);


--
-- Name: academic_year_table academic_year_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_year_table
    ADD CONSTRAINT academic_year_table_pkey PRIMARY KEY (id);


--
-- Name: bce_table bce_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bce_table
    ADD CONSTRAINT bce_table_pkey PRIMARY KEY (id);


--
-- Name: daily_faculty_updates daily_faculty_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_faculty_updates
    ADD CONSTRAINT daily_faculty_updates_pkey PRIMARY KEY (update_id);


--
-- Name: dept_table dept_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dept_table
    ADD CONSTRAINT dept_table_pkey PRIMARY KEY (id);


--
-- Name: faculty_all_records faculty_all_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_all_records
    ADD CONSTRAINT faculty_all_records_pkey PRIMARY KEY (faculty_id);


--
-- Name: faculty_request faculty_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_request
    ADD CONSTRAINT faculty_request_pkey PRIMARY KEY (id);


--
-- Name: paper_id_table paper_id_table_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paper_id_table
    ADD CONSTRAINT paper_id_table_id_unique UNIQUE (id);


--
-- Name: semester_table semester_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.semester_table
    ADD CONSTRAINT semester_table_pkey PRIMARY KEY (id);


--
-- Name: bce_table unique_bce_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bce_table
    ADD CONSTRAINT unique_bce_id UNIQUE (bce_id);


--
-- Name: course_table unique_course_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_table
    ADD CONSTRAINT unique_course_id UNIQUE (course_id);


--
-- Name: dept_table unique_dept_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dept_table
    ADD CONSTRAINT unique_dept_name UNIQUE (dept_name);


--
-- Name: faculty_all_records unique_faculty_paper; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_all_records
    ADD CONSTRAINT unique_faculty_paper UNIQUE (faculty_id, paper_id);


--
-- Name: semester_table unique_sem_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.semester_table
    ADD CONSTRAINT unique_sem_code UNIQUE (sem_code);


--
-- Name: user_table user_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_table
    ADD CONSTRAINT user_table_pkey PRIMARY KEY (user_id);


--
-- Name: dept_table set_created_at_updated_at_course; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_created_at_updated_at_course BEFORE INSERT OR UPDATE ON public.dept_table FOR EACH ROW EXECUTE FUNCTION public.set_created_at_updated_at();


--
-- Name: faculty_request set_created_at_updated_at_course; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_created_at_updated_at_course BEFORE INSERT OR UPDATE ON public.faculty_request FOR EACH ROW EXECUTE FUNCTION public.set_created_at_updated_at();


--
-- Name: faculty_table set_created_at_updated_at_course; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_created_at_updated_at_course BEFORE INSERT OR UPDATE ON public.faculty_table FOR EACH ROW EXECUTE FUNCTION public.set_created_at_updated_at();


--
-- Name: semester_table set_created_at_updated_at_course; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_created_at_updated_at_course BEFORE INSERT OR UPDATE ON public.semester_table FOR EACH ROW EXECUTE FUNCTION public.set_created_at_updated_at();


--
-- Name: course_table set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.course_table FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: bce_table set_updatedat; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updatedat BEFORE UPDATE ON public.bce_table FOR EACH ROW EXECUTE FUNCTION public.update_updatedat_column();


--
-- Name: daily_faculty_updates trigger_update_paper_corrected; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_paper_corrected BEFORE INSERT ON public.daily_faculty_updates FOR EACH ROW EXECUTE FUNCTION public.update_paper_corrected();


--
-- Name: daily_faculty_updates daily_faculty_updates_faculty_id_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_faculty_updates
    ADD CONSTRAINT daily_faculty_updates_faculty_id_paper_id_fkey FOREIGN KEY (faculty_id, paper_id) REFERENCES public.faculty_all_records(faculty_id, paper_id);


--
-- Name: faculty_request faculty_request_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_request
    ADD CONSTRAINT faculty_request_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.course_table(course_id);


--
-- Name: faculty_request faculty_request_faculty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_request
    ADD CONSTRAINT faculty_request_faculty_id_fkey FOREIGN KEY (faculty_id) REFERENCES public.faculty_all_records(faculty_id) ON DELETE CASCADE;


--
-- Name: faculty_request faculty_request_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_request
    ADD CONSTRAINT faculty_request_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.paper_id_table(id);


--
-- Name: faculty_table faculty_table_dept_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_table
    ADD CONSTRAINT faculty_table_dept_fkey FOREIGN KEY (dept) REFERENCES public.dept_table(id);


--
-- Name: faculty_request fk_bce_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_request
    ADD CONSTRAINT fk_bce_id FOREIGN KEY (bce_id) REFERENCES public.bce_table(id);


--
-- Name: bce_table fk_dept_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bce_table
    ADD CONSTRAINT fk_dept_id FOREIGN KEY (dept_id) REFERENCES public.dept_table(id) ON DELETE SET NULL;


--
-- Name: course_table fk_sem_code; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_table
    ADD CONSTRAINT fk_sem_code FOREIGN KEY (sem_code) REFERENCES public.semester_table(sem_code) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

