CREATE TABLE IF NOT EXISTS users(
  id SERIAL PRIMARY KEY,
  role VARCHAR(20) NOT NULL CHECK(role IN ('parent','teacher','kid')),
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(180) UNIQUE,
  password_hash TEXT,
  student_code VARCHAR(50) UNIQUE,
  pin_hash TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS kid_profiles(
  user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  parent_id INTEGER REFERENCES users(id),
  teacher_id INTEGER REFERENCES users(id),
  state VARCHAR(80), board VARCHAR(120), standard VARCHAR(20), language VARCHAR(120),
  subjects JSONB DEFAULT '[]'::jsonb, interests JSONB DEFAULT '[]'::jsonb
);
CREATE TABLE IF NOT EXISTS learning_sessions(
  id BIGSERIAL PRIMARY KEY,kid_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  login_at TIMESTAMPTZ DEFAULT NOW(),logout_at TIMESTAMPTZ,duration_seconds INTEGER DEFAULT 0,active BOOLEAN DEFAULT TRUE
);
CREATE TABLE IF NOT EXISTS activities(
  id BIGSERIAL PRIMARY KEY,kid_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  activity_type VARCHAR(50),subject VARCHAR(100),title VARCHAR(255),metadata JSONB DEFAULT '{}'::jsonb,created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS notifications(
  id BIGSERIAL PRIMARY KEY,user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,kid_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(60),message TEXT,is_read BOOLEAN DEFAULT FALSE,created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS teacher_assignments(
  id BIGSERIAL PRIMARY KEY,teacher_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  board VARCHAR(120),standard VARCHAR(20),subject VARCHAR(100),topic VARCHAR(180),instructions TEXT,
  assignment_date DATE DEFAULT CURRENT_DATE,created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS quiz_attempts(
  id BIGSERIAL PRIMARY KEY,kid_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  subject VARCHAR(100),topic VARCHAR(180),board VARCHAR(120),standard VARCHAR(20),score INTEGER,total INTEGER,
  percent NUMERIC(5,2),detail JSONB DEFAULT '[]'::jsonb,source VARCHAR(30) DEFAULT 'ai',created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS ai_quiz_sessions(
  id UUID PRIMARY KEY,kid_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  subject VARCHAR(100),topic VARCHAR(180),questions JSONB NOT NULL,created_at TIMESTAMPTZ DEFAULT NOW(),submitted_at TIMESTAMPTZ
);
CREATE TABLE IF NOT EXISTS mastery(
  kid_id INTEGER REFERENCES users(id) ON DELETE CASCADE,subject VARCHAR(100),topic VARCHAR(180),
  score NUMERIC(5,2) DEFAULT 50,attempts INTEGER DEFAULT 0,correct_answers INTEGER DEFAULT 0,
  last_practiced_at TIMESTAMPTZ DEFAULT NOW(),next_revision_at TIMESTAMPTZ,
  PRIMARY KEY(kid_id,subject,topic)
);
CREATE TABLE IF NOT EXISTS ai_chat_messages(
  id BIGSERIAL PRIMARY KEY,kid_id INTEGER REFERENCES users(id) ON DELETE CASCADE,subject VARCHAR(100),
  role VARCHAR(20) CHECK(role IN ('user','assistant')),content TEXT NOT NULL,created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS push_subscriptions(
  id BIGSERIAL PRIMARY KEY,user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,endpoint TEXT NOT NULL UNIQUE,
  subscription JSONB NOT NULL,created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_sessions_kid ON learning_sessions(kid_id,login_at DESC);
CREATE INDEX IF NOT EXISTS idx_activities_kid ON activities(kid_id,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_quizzes_kid ON quiz_attempts(kid_id,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_kid ON ai_chat_messages(kid_id,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_push_user ON push_subscriptions(user_id);
