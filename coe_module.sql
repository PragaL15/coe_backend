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
    NEW.paper_corrected := (
        SELECT paper_corrected
        FROM faculty_all_records
        WHERE faculty_id = NEW.faculty_id
    );
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
    reason text,
    paper_id integer,
    bce_id integer,
    status integer
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
-- Name: price_calculation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_calculation (
    id integer NOT NULL,
    faculty_id integer,
    paper_corrected integer NOT NULL,
    price double precision NOT NULL,
    amt_given double precision GENERATED ALWAYS AS (((paper_corrected)::double precision * price)) STORED
);


ALTER TABLE public.price_calculation OWNER TO postgres;

--
-- Name: price_calculation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.price_calculation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.price_calculation_id_seq OWNER TO postgres;

--
-- Name: price_calculation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.price_calculation_id_seq OWNED BY public.price_calculation.id;


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
-- Name: price_calculation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_calculation ALTER COLUMN id SET DEFAULT nextval('public.price_calculation_id_seq'::regclass);


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
7	2026-2027	2025-01-29 01:45:34.502315	2025-01-29 01:45:34.502315	1
8	2027-2028	2025-01-29 01:47:38.649076	2025-01-29 01:47:38.649076	1
9	2027-2028	2025-01-29 01:50:24.721346	2025-01-29 01:50:24.721346	1
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
12	117	BCE1234	Dr.Kalai	f	2025-01-29 01:49:07.851065	2025-01-29 01:49:07.851065	9876542319	kalai@bitsathy.ac.in
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
114	22CD108	Theory of computing	1	2025-01-29 01:45:18.905846	2025-01-29 01:45:18.905846	SEM101
115	22CD123	Engineering Math III	1	2025-01-29 01:47:19.420218	2025-01-29 01:47:19.420218	SEM203
\.


--
-- Data for Name: daily_faculty_updates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daily_faculty_updates (update_id, faculty_id, paper_id, paper_corrected_today, remarks, createdat) FROM stdin;
13	3	3	20	nil	2025-01-27 01:03:26.096519
14	3	3	76	nil	2025-01-27 12:09:14.76131
16	3	3	9	corrected 9 papers	2025-01-28 23:26:54.500485
17	3	3	9	corrected 9 paper	2025-01-28 23:29:19.918627
19	3	3	7	Corrected 7 papers today	2025-01-28 23:58:02.773683
20	3	3	10	corrected 10 papers	2025-01-28 23:58:54.51595
21	3	3	3	b	2025-01-29 00:05:13.76326
22	3	3	6	complete correction of 6 papers	2025-01-29 00:08:12.795929
23	3	3	23	corrected 23 papers	2025-01-29 00:19:45.147587
24	3	3	9	Corrected 9 papers 	2025-01-29 00:23:49.322981
25	3	3	3	corrected 3 papers 	2025-01-29 00:33:15.992706
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
112	Test Department	1	2025-01-25 20:53:01.585656	2025-01-25 20:53:01.585656
2	Electronic and communication	1	2025-01-25 00:24:56.217741	2025-01-29 00:54:51.340272
0	Computer Science and Design	1	2025-01-25 21:05:52.689722	2025-01-29 00:54:51.340272
113	Information Technology	1	2025-01-25 21:27:22.694323	2025-01-29 00:54:51.340272
114	Computer Technology	1	2025-01-25 21:27:39.550096	2025-01-29 00:54:51.340272
115	Computer Science and Engineering	1	2025-01-25 22:36:13.052273	2025-01-29 00:54:51.340272
116	Information Science Engineering	1	2025-01-28 11:38:04.757445	2025-01-29 00:54:51.340272
117	Mechatronics	1	2025-01-29 01:48:12.408107	2025-01-29 01:48:12.408107
\.


--
-- Data for Name: faculty_all_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faculty_all_records (faculty_id, course_id, paper_allocated, deadline, status, bce_id, sem_code, dept_id, paper_corrected, paper_id) FROM stdin;
3	103	150	15	3	BCE125	CS103	12	112	3
237	104	50	5	0	BCE1002	SEM201	113	\N	\N
236	101	130	10	0	BCE1001	SEM201	2	9	\N
\.


--
-- Data for Name: faculty_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faculty_request (id, faculty_id, papers_left, course_id, remarks, approval_status, createdat, updatedat, deadline_left, sem_code, reason, paper_id, bce_id, status) FROM stdin;
36	3	38	103	Due to sudden illness	1	2025-01-29 00:33:45.749702	2025-01-29 09:01:09.947941	2	CS103		\N	\N	0
37	3	38	103	The pending pages are uploaded	0	2025-01-29 11:04:27.875054	2025-01-29 11:04:27.875054	0	CS103	\N	\N	\N	0
\.


--
-- Data for Name: faculty_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.faculty_table (faculty_id, faculty_name, dept, status, createdat, updatedat, mobile_num, email) FROM stdin;
3	Dr.R.Gomathi	103	1	2025-01-22 16:28:03.411904	2025-01-29 00:07:02.095909	9876543212	\N
236	Sasikala	113	1	2025-01-29 00:39:31.025066	2025-01-29 00:39:31.025066	9876543210	sasikala@example.com
237	Sumathi	115	1	2025-01-29 00:39:31.025066	2025-01-29 00:39:31.025066	8765432109	sumathi@example.com
238	Dr.Mohan	114	1	2025-01-29 01:49:46.055347	2025-01-29 01:49:46.055347	8765934123	mohan@bithsathy.ac.in
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
-- Data for Name: price_calculation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_calculation (id, faculty_id, paper_corrected, price) FROM stdin;
1	3	112	10.5
2	3	112	10.5
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
11	CS103	2024-2025	1	2025-01-28 22:59:18.975756	2025-01-28 22:59:18.975756
13	SEM345	2027-2028	1	2025-01-29 01:47:55.68267	2025-01-29 01:47:55.68267
\.


--
-- Data for Name: user_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_table (user_id, user_name, password, role_id, status) FROM stdin;
1	john_doe	password123	1	t
3	alex_jones	$2b$12$IjPbYCrSviYhh/Mt3lT/vOP59J4wmoUkkhbmoN6AjH1L4o.SbyXb6\n	3	t
2	jane_smith	$2b$12$g/HWz/ojD5t1R93hA.b9YuXPNU8allfnZdaEGFfnJpbDIO8f/tCFG	2	t
\.


--
-- Name: academic_year_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.academic_year_table_id_seq', 9, true);


--
-- Name: bce_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bce_table_id_seq', 12, true);


--
-- Name: course_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_id_seq', 115, true);


--
-- Name: daily_faculty_updates_update_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.daily_faculty_updates_update_id_seq', 25, true);


--
-- Name: dept_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dept_table_id_seq', 117, true);


--
-- Name: faculty_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.faculty_id_seq', 238, true);


--
-- Name: faculty_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.faculty_request_id_seq', 37, true);


--
-- Name: paper_id_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.paper_id_table_id_seq', 3, true);


--
-- Name: price_calculation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_calculation_id_seq', 2, true);


--
-- Name: semester_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.semester_table_id_seq', 14, true);


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
-- Name: price_calculation price_calculation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_calculation
    ADD CONSTRAINT price_calculation_pkey PRIMARY KEY (id);


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
-- Name: user_table unique_role_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_table
    ADD CONSTRAINT unique_role_id UNIQUE (role_id);


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
-- Name: price_calculation set_paper_corrected; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_paper_corrected BEFORE INSERT ON public.price_calculation FOR EACH ROW EXECUTE FUNCTION public.update_paper_corrected();


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
-- Name: faculty_request fk_sem_code; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.faculty_request
    ADD CONSTRAINT fk_sem_code FOREIGN KEY (sem_code) REFERENCES public.semester_table(sem_code) ON DELETE SET NULL;


--
-- Name: price_calculation price_calculation_faculty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_calculation
    ADD CONSTRAINT price_calculation_faculty_id_fkey FOREIGN KEY (faculty_id) REFERENCES public.faculty_all_records(faculty_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

