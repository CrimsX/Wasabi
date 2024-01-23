CREATE DATABASE wasabi;

USE wasabi;

CREATE TABLE client (
    UserID VARCHAR(20) PRIMARY KEY,
    Firstname VARCHAR(1000) NOT NULL,
    Lastname VARCHAR(1000) NOT NULL,
    Pass VARCHAR(30) NOT NULL
    );

CREATE TABLE friends (
    UserID VARCHAR(20),
    FriendID VARCHAR(20)
)

CREATE TABLE encryption (
    EncryptID INTEGER PRIMARY KEY,
    EncryptedMsg VARCHAR(500),
    EncryptionKey VARCHAR(500)
    );

CREATE TABLE messages (
    MessageID INTEGER PRIMARY KEY AUTO_INCREMENT,
    DateReceived BIGINT NOT NULL,
    DataSent VARCHAR(500) NOT NULL,
    MsgContent VARCHAR(500) NOT NULL,
    EncryptID Integer,
    ChatID Integer,
    FOREIGN KEY (EncryptID) REFERENCES encryption(EncryptID)
    );

CREATE TABLE privatechat (
    ChatID Integer NOT NULL PRIMARY KEY AUTO_INCREMENT,
    User1 VARCHAR(20),
    User2 VARCHAR(20)
    );


CREATE TABLE receivedmessages (
    UserID VARCHAR(20),
    MessageID INTEGER,
    FOREIGN KEY (UserID) REFERENCES client(UserID),
    FOREIGN KEY (MessageID) REFERENCES messages(MessageID)
    );

CREATE TABLE sentmessages (
    UserID VARCHAR(20),
    MessageID INTEGER,
    FOREIGN KEY (UserID) REFERENCES client(UserID),
    FOREIGN KEY (MessageID) REFERENCES messages(MessageID)
    );

CREATE TABLE servertable (
    ServerID INTEGER PRIMARY KEY,
    ServerName VARCHAR(50) NOT NULL,
    CreationDate VARCHAR(15)
    );

CREATE TABLE partof (
    UserID VARCHAR(20),
    ServerID INTEGER,
    FOREIGN KEY (ServerID) REFERENCES servertable(ServerID),
    FOREIGN KEY (UserID) REFERENCES client(UserID)
    );

CREATE TABLE document (
    DocumentID INTEGER PRIMARY KEY,
    UserID VARCHAR(20),
    DocumentTitle VARCHAR(50),
    Content VARCHAR(5000),
    DateCreated VARCHAR(15),
    LastModifiedDate VARCHAR(15),
    FOREIGN Key (UserID) REFERENCES client(UserID)
    );

CREATE TABLE access (
    DocumentID INTEGER,
    UserID VARCHAR(20),
    Privilege VARCHAR(10),
    FOREIGN Key (UserID) REFERENCES client(UserID),
    FOREIGN Key (DocumentID) REFERENCES document(DocumentID)
    );

CREATE TABLE callinfo (
    CallID INTEGER PRIMARY KEY,
    StartTime VARCHAR(20),
    EndTime VARCHAR(20),
    Duration VARCHAR(15),
    CallType VARCHAR(15),
    Online_status VARCHAR(15),
    CallerID VARCHAR(20),
    FOREIGN KEY (CallerID) REFERENCES client(UserID)
    );

CREATE TABLE ReceiveCall (
    CallID VARCHAR(20),
    ReceiverID VARCHAR(20),
    FOREIGN Key (CallID) REFERENCES client(UserID),
    FOREIGN Key (ReceiverID) REFERENCES client(UserID)
    );
