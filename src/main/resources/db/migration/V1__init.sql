CREATE TABLE users
(
    id       SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL
);

CREATE TABLE profiles
(
    id             SERIAL PRIMARY KEY,
    bio            TEXT,
    twitter_handle VARCHAR(255),
    user_id        INTEGER UNIQUE, -- UNIQUE enforces the 1:1 relationship
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users (id)
);

INSERT INTO users (username)
VALUES ('alex_j');

INSERT INTO profiles (bio, twitter_handle, user_id)
VALUES ('Software Engineer', '@alex_dev', 1);
