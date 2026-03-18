CREATE DATABASE decp_user_db;
CREATE DATABASE decp_job_db;
CREATE DATABASE decp_event_db;
CREATE DATABASE decp_research_db;
CREATE DATABASE decp_analytics_db;
CREATE DATABASE decp_mentorship_db;

GRANT ALL PRIVILEGES ON DATABASE decp_user_db TO decp_user;
GRANT ALL PRIVILEGES ON DATABASE decp_job_db TO decp_user;
GRANT ALL PRIVILEGES ON DATABASE decp_event_db TO decp_user;
GRANT ALL PRIVILEGES ON DATABASE decp_research_db TO decp_user;
GRANT ALL PRIVILEGES ON DATABASE decp_analytics_db TO decp_user;
GRANT ALL PRIVILEGES ON DATABASE decp_mentorship_db TO decp_user;
