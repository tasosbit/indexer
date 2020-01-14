-- TODO? replace all 'addr bytea' with 'addr_id bigint' and a mapping table? makes addrs an 8 byte int that fits in a register instead of a 32 byte string

CREATE TABLE IF NOT EXISTS block_header (
round bigint PRIMARY KEY,
realtime timestamp without time zone NOT NULL,
header bytea NOT NULL
);
CREATE INDEX IF NOT EXISTS block_header_time ON block_header (realtime);

CREATE TABLE IF NOT EXISTS txn (
round bigint NOT NULL,
intra smallint NOT NULL,
typeenum smallint NOT NULL,
asset bigint NOT NULL, -- 0=Algos, otherwise AssetIndex
-- txid bytea NOT NULL, -- TODO? [32]byte. Index on this as a way of extending transaction-status checking into the past for things we submitted?
txnbytes bytea NOT NULL,
txn jsonb NOT NULL,
PRIMARY KEY ( round, intra )
);

CREATE TABLE IF NOT EXISTS txn_participation (
addr bytea NOT NULL,
round bigint NOT NULL,
intra smallint NOT NULL
);
CREATE INDEX IF NOT EXISTS txn_participation_i ON txn_participation ( addr, round DESC, intra DESC );

-- bookeeping for local file import
CREATE TABLE IF NOT EXISTS imported (path text);

-- like ledger/accountdb.go
DROP TABLE IF EXISTS accounttotals;
-- CREATE TABLE IF NOT EXISTS accounttotals (
--   id text primary key,
--   online integer,
--   onlinerewardunits integer,
--   offline integer,
--   offlinerewardunits integer,
--   notparticipating integer,
--   notparticipatingrewardunits integer,
--   rewardslevel integer);

-- expand data.basics.AccountData
CREATE TABLE IF NOT EXISTS account (
  addr bytea primary key,
  microalgos bigint NOT NULL,
  account_data jsonb NOT NULL -- data.basics.AccountData except AssetParams and Assets
);

-- data.basics.AccountData Assets[asset id] AssetHolding{}
CREATE TABLE IF NOT EXISTS account_asset (
  addr bytea NOT NULL, -- [32]byte
  assetid bigint NOT NULL,
  amount bigint NOT NULL,
  frozen boolean NOT NULL,
  PRIMARY KEY (addr, assetid)
);

-- data.basics.AccountData AssetParams[index] AssetParams{}
CREATE TABLE IF NOT EXISTS asset (
  index bigint PRIMARY KEY,
  creator_addr bytea NOT NULL,
  params jsonb NOT NULL -- data.basics.AssetParams -- TODO index some fields?
);
-- TODO: index on creator_addr

-- subsumes ledger/accountdb.go accounttotals and acctrounds
-- "state":{online, onlinerewardunits, offline, offlinerewardunits, notparticipating, notparticipatingrewardunits, rewardslevel, round bigint}
CREATE TABLE IF NOT EXISTS metastate (
  k text primary key,
  v jsonb
);
