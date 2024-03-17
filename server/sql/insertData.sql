/* Create users */
/* Username: user1, Password: 1234 */
insert into client values('user1', 'user1', '$2b$10$VOGsbVSJYCYjlxi0NcqQt.ogYqpyzr0nl827YlS2Jn786kZPKptYq');
insert into client values('user2', 'user2', '$2b$10$VOGsbVSJYCYjlxi0NcqQt.ogYqpyzr0nl827YlS2Jn786kZPKptYq');
insert into client values('user3', 'user3', '$2b$10$VOGsbVSJYCYjlxi0NcqQt.ogYqpyzr0nl827YlS2Jn786kZPKptYq');

/* Create friends */
insert into friends values('user1', 'user2');
insert into friends values('user2', 'user1');
insert into friends values('user1', 'user3');
insert into friends values('user3', 'user1');

/* Create servers */
insert into servertable (ServerName, CreationDate, Owner) values ('test group 1', '1707169256897', 'user1');

/* Add users to servers */
insert into partof values ('user1', 1);
insert into partof values ('user2', 1);
insert into partof values ('user3', 1);
