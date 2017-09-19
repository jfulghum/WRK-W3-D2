DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL

);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES users(id)
);

-- join table exists to join tables together
DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,

  q_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY(q_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  q_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  reply_parent_id INTEGER,

  FOREIGN KEY(q_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(reply_parent_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  q_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,


  FOREIGN KEY(q_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Johanna', 'Fulghum'),
  ('Oguzhan', 'Cakmak'),
  ('Patrick', 'Fulghum');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('What planet is this?', 'Help me please', 1),
  ('SQL Help', 'I couldn''t solve my problem Help!', 2);

INSERT INTO
  replies (body, q_id, user_id, reply_parent_id)
VALUES
  ('Earth', 1, 1, NULL),
  ('Looks like Mars to me!! Loser', 1, 2, 1),
  ('No help here man.', 2, 1, NULL),
  ('I can help! SQL is great', 2, 3, 3);

INSERT INTO
  question_likes (q_id, user_id)
VALUES
  (1, 2),
  (2, 3);
