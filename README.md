\# AI Job Market Analysis



An end-to-end data analytics project analyzing the AI job market using \*\*Excel, Python, PostgreSQL, SQL, and Power BI\*\*.



The project focuses on understanding AI job demand, salaries, required skills, experience levels, remote-work opportunities, and geographic patterns through data cleaning, relational database design, SQL analysis, and an interactive Power BI dashboard.



\---



\## 📌 Project Overview



The AI job market is rapidly evolving, with changes in required skills, salary levels, job demand, and remote-work opportunities.



This project analyzes AI-related job data to identify meaningful patterns across:



\- Job roles and categories

\- Required technical skills

\- Experience levels

\- Salary ranges

\- Job demand

\- Demand growth

\- Remote-work opportunities

\- Locations

\- Company size

\- Industry

\- AI salary premium

\- Benefits



The project follows a complete analytics workflow:



\*\*Excel → Python Data Profiling \& Cleaning → PostgreSQL → SQL Analysis → Power BI Dashboard\*\*



\---



\## 🎯 Project Objectives



\- Understand the distribution of AI-related jobs.

\- Identify frequently required skills.

\- Analyze salary patterns across roles and experience levels.

\- Examine demand and demand growth.

\- Analyze remote-work opportunities.

\- Compare AI job opportunities across locations.

\- Structure the raw dataset into a relational PostgreSQL database.

\- Use SQL to perform analytical queries.

\- Build an interactive Power BI dashboard to communicate findings.



\---



\## 🛠️ Tools \& Technologies



| Tool / Technology | Usage |

|---|---|

| \*\*Excel\*\* | Source dataset and initial data handling |

| \*\*Python\*\* | Data profiling, cleaning, transformation, and preparation |

| \*\*Pandas\*\* | Data inspection and manipulation |

| \*\*PostgreSQL\*\* | Relational database |

| \*\*SQL\*\* | Data analysis and querying |

| \*\*Power BI\*\* | Interactive dashboard and visualization |

| \*\*Jupyter Notebook\*\* | Python-based data profiling and analysis |



\---



\## 📊 Dataset



The dataset contains \*\*1,500 AI-related job records\*\* with attributes covering job information, salary, demand, skills, location, and other job characteristics.



\### Major Columns



\- `job\_id`

\- `job\_title`

\- `job\_category`

\- `experience\_level`

\- `years\_of\_experience`

\- `education\_required`

\- `annual\_salary\_usd`

\- `salary\_min\_usd`

\- `salary\_max\_usd`

\- `city`

\- `country`

\- `remote\_work`

\- `company\_size`

\- `industry`

\- `required\_skills`

\- `ai\_salary\_premium\_pct`

\- `demand\_score`

\- `demand\_growth\_yoy\_pct`

\- `benefits\_score\_10`

\- `posting\_year`

\- `posting\_month`

\- `is\_senior`

\- `is\_remote\_friendly`

\- `is\_llm\_role`

\- `salary\_tier`



\---



\# 🔍 Data Profiling \& Cleaning



Data profiling and preparation were performed using \*\*Python and Pandas\*\* before loading the data into the PostgreSQL database.



\### Data Profiling



The dataset was examined for:



\- Dataset structure and dimensions

\- Column data types

\- Missing values

\- Duplicate records

\- Unique values

\- Categorical distributions

\- Data consistency

\- Relationships between columns



\### Data Cleaning \& Transformation



The preparation process included:



\- Checking and handling missing values

\- Checking duplicate records

\- Validating column values and data types

\- Separating multi-valued skill information

\- Extracting individual skills from the `required\_skills` field

\- Creating unique skill records

\- Creating unique location records

\- Preparing data for relational database storage

\- Removing duplicate job-skill combinations

\- Validating the final tables before database loading



The original `required\_skills` field contained multiple skills separated by `|`. These skills were separated and transformed into individual records so that the data could be properly represented in a relational database.



\### Data Preparation Results



| Entity | Records |

|---|---:|

| Jobs | 1,500 |

| Locations | 20 |

| Skills | 93 |

| Demand Metrics | 1,500 |

| Job-Skill Relationships | 9,428 |



The job-skill relationship table initially contained duplicate job-skill combinations. After removing \*\*120 duplicate pairs\*\*, the final table contained \*\*9,428 unique relationships\*\*.



\---



\# 🗄️ PostgreSQL Database Design



The cleaned data was transformed into a relational database structure to reduce redundancy and support efficient SQL analysis.



\### Database Schema



```text

&#x20;                   ┌──────────────┐

&#x20;                   │  locations   │

&#x20;                   └──────┬───────┘

&#x20;                          │

&#x20;                          │

&#x20;                   ┌──────▼───────┐

&#x20;                   │     jobs     │

&#x20;                   └───┬──────┬───┘

&#x20;                       │      │

&#x20;            ┌──────────┘      └──────────────┐

&#x20;            │                                │

&#x20;     ┌──────▼───────┐                ┌──────▼──────────┐

&#x20;     │ demand\_metrics│                │   job\_skills    │

&#x20;     └──────────────┘                └──────┬──────────┘

&#x20;                                            │

&#x20;                                     ┌──────▼───────┐

&#x20;                                     │    skills    │

&#x20;                                     └──────────────┘

```



\### Main Tables



\#### `jobs`



Stores the primary job-level information including:



\- Job title

\- Job category

\- Experience

\- Education

\- Salary

\- Location

\- Remote work

\- Company size

\- Industry



\#### `locations`



Stores unique combinations of:



\- City

\- Country



A `location\_id` is used to connect locations with jobs.



\#### `skills`



Stores the unique skills extracted from the original `required\_skills` column.



\#### `job\_skills`



A bridge table connecting jobs and skills.



This handles the \*\*many-to-many relationship\*\* between jobs and required skills.



\#### `demand\_metrics`



Stores analytical metrics including:



\- Demand score

\- Demand growth

\- Benefits score

\- AI salary premium



\---



\## 🔗 Database Relationships



The database uses primary and foreign keys to connect the tables.



```text

locations

&#x20;  1

&#x20;  │

&#x20;  │

&#x20;  └──────────< jobs



jobs

&#x20;  1

&#x20;  │

&#x20;  ├──────────< demand\_metrics

&#x20;  │

&#x20;  └──────────< job\_skills >──────────1 skills

```



This relational structure avoids storing repeated skill and location information inside every job record.



\---



\# 🧮 SQL Analysis



SQL was used with PostgreSQL to analyze the structured job-market data.



The analysis focuses on questions such as:



\- Which skills are most frequently required?

\- How does salary vary by experience level?

\- Which job categories have higher demand?

\- How does demand relate to salary?

\- How do salaries differ across locations?

\- What is the distribution of remote jobs?

\- How does AI salary premium vary across jobs?

\- Which locations have greater concentrations of AI opportunities?

\- How do job characteristics vary across experience levels?



SQL queries were performed on the normalized relational tables rather than relying only on the original flat dataset.



SQL file:



`postgersql.sql`



\---



\# 📊 Power BI Dashboard



The cleaned and structured data was used to create a \*\*four-page Power BI dashboard\*\*.



The dashboard is designed to move from an overall market view into skills, salary/career analysis, and geographic insights.



\---



\## 1️⃣ Executive Insights



Provides a high-level overview of the AI job market.



\### Includes



\- Key job-market KPIs

\- Average demand

\- AI salary premium

\- Job distribution

\- Experience-level insights

\- Executive findings

\- Key findings and recommendations



This page provides a quick overview before moving into detailed analysis.



\---



\## 2️⃣ Skills Analysis



Focuses on the skills required across AI-related roles.



\### Includes



\- In-demand skills

\- Skill frequency

\- Skill relationships with job demand

\- Skill-related salary patterns

\- Job-category comparisons



This page helps identify the technical skills appearing most frequently across the dataset.



\---



\## 3️⃣ Salary \& Career Insights



Focuses on compensation and career-level patterns.



\### Includes



\- Salary analysis

\- Salary by experience level

\- Salary tiers

\- Demand vs. salary analysis

\- AI salary premium

\- Career-level comparisons



The page helps examine how compensation and demand vary across different career stages and job characteristics.



\---



\## 4️⃣ Geographic Market Insights



Focuses on the geographic distribution of AI opportunities.



\### Includes



\- Jobs by location

\- Salary by location

\- Demand by location

\- Remote-work opportunities

\- Geographic comparisons



A \*\*Decomposition Tree\*\* is used in the dashboard to explore geographic and job-market dimensions.



\---



\# 💡 Key Analytical Areas



The project investigates several business questions:



\### Skills

\- What skills are most commonly required?

\- How are skills distributed across AI roles?

\- Which skills are associated with different job categories?



\### Salary

\- How does salary change with experience?

\- How are jobs distributed across salary tiers?

\- What is the relationship between demand and salary?

\- How does AI salary premium vary?



\### Demand

\- Which job categories show higher demand?

\- How does demand growth vary?

\- What characteristics are associated with demand?



\### Geography

\- Where are AI jobs concentrated?

\- How do salaries differ by location?

\- How does remote work vary across locations?



\---



\# 📷 Dashboard Preview



> Add your Power BI dashboard images to the `powerbi\_dashboard` folder before pushing this README.



\### Executive Insights



!\[Executive Insights](powerbi\_dashboard/executive\_summary.png)



\### Skills Analysis



!\[Skills Analysis](powerbi\_dashboard/skills\_analysis.png)



\### Salary \& Career Insights



!\[Salary \& Career Insights](powerbi\_dashboard/salary\_career\_insights.png)



\### Geographic Market Insights



!\[Geographic Market Insights](powerbi\_dashboard/geographic\_market\_insights.png)



\---



\# 📂 Project Structure



```text

ai-job-market-analysis/

│

├── README.md

├── .gitignore

│

├── data/

│   └── ai\_jobs.xlsx

│

├── notebook/

│   └── data\_profiling.ipynb

│

├── sql/

│   └── postgersql.sql

│

└── powerbi\_dashboard/

&#x20;   ├── executive\_summary.png

&#x20;   ├── skills\_analysis.png

&#x20;   ├── salary\_career\_insights.png

&#x20;   └── geographic\_market\_insights.png

```



\---



\# 🔄 Project Workflow



```text

Excel Dataset

&#x20;     │

&#x20;     ▼

Python + Pandas

&#x20;     │

&#x20;     ├── Data Profiling

&#x20;     ├── Missing Value Checks

&#x20;     ├── Duplicate Checks

&#x20;     ├── Skill Extraction

&#x20;     ├── Data Cleaning

&#x20;     └── Data Transformation

&#x20;     │

&#x20;     ▼

PostgreSQL

&#x20;     │

&#x20;     ├── Jobs

&#x20;     ├── Locations

&#x20;     ├── Skills

&#x20;     ├── Job Skills

&#x20;     └── Demand Metrics

&#x20;     │

&#x20;     ▼

SQL Analysis

&#x20;     │

&#x20;     ▼

Power BI

&#x20;     │

&#x20;     ▼

Interactive AI Job Market Dashboard

```



\---



\# 📚 Skills Demonstrated



\- Data Profiling

\- Data Cleaning

\- Data Transformation

\- Exploratory Data Analysis

\- Python

\- Pandas

\- SQL

\- PostgreSQL

\- Relational Database Design

\- Database Normalization

\- Primary \& Foreign Keys

\- Many-to-Many Relationships

\- Duplicate Detection

\- Data Validation

\- Data Visualization

\- Power BI Dashboard Development

\- Business Analysis

\- Analytical Storytelling



\---



\## 👩‍💻 Author



\*\*Bora Asushma\*\*



B.Tech / CSE — Data Science



Interested in Data Analytics, SQL, Python, Excel, PostgreSQL, and Power BI.

