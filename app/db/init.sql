-- Define a tabela 'accounts'
CREATE TABLE IF NOT EXISTS accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) NOT NULL,
    limit_amount INTEGER NOT NULL
);

-- Define a tabela 'transactions'
CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    transaction_type CHAR(1) NOT NULL,
    description VARCHAR(100) NOT NULL,
    date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);

-- Define a tabela 'balances'
CREATE TABLE IF NOT EXISTS balances (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);

-- Insere os dados iniciais na tabela 'accounts' e 'balances'
INSERT INTO accounts (name, limit_amount) VALUES
    ('o barato sai caro', 100000),
    ('zan corp ltda', 80000),
    ('les cruders', 1000000),
    ('padaria joia de cocaia', 10000000),
    ('kid mais', 500000);

INSERT INTO balances (account_id, amount)
    SELECT id, 0 FROM accounts;
