-- 表：20张
-- 表枚举：tag、value、business、tag_business、config、log
--        field、datatype、msgtype、msgformat、msglist
--        msgresult_binary、msgresult_binary_bat、msgresult_fix_bat、msgresult_fix
--        respond、outputformat、repeat
--        business_other、column
-- 由于开发时间紧张，没有遵守所有数据库范式，后续有机会再优化，敬请谅解，欢迎交流提建议。
--------------------------------------------------
-- Tag
-- ：STEP 标签
--------------------------------------------------
create table tag
(
	tag int not null       -- FIX消息的 Tag值
		constraint tag_pk
			primary key,
	name_en text,          -- Tag英文释义
	name_cn text,          -- Tag中文释义
	description_cn text,   -- 中文说明
	description_en text    -- 英文说明
	
);

create unique index tag_tag_uindex
	on tag (tag);
--------------------------------------------------
-- Tag
--------------------------------------------------


--------------------------------------------------
-- Value
-- ：域值
--------------------------------------------------
create table value
(
	tag_business_id INTEGER,
	value text,
	meaning_en text,
	meaning_cn text,
	description_cn text,
	description_en text,
	remark text
);
--------------------------------------------------
-- Value
--------------------------------------------------

--------------------------------------------------
-- Business
-- ：业务
--------------------------------------------------
create table business
(
	id INTEGER not null                  -- 业务ID
		constraint business_pk
			primary key autoincrement,
	name text                            -- 业务名称
);

create unique index business_id_uindex
	on business (id);
--------------------------------------------------
-- Business
--------------------------------------------------

--------------------------------------------------
-- Tag-Business
-- ：域对于某个业务的意义
--------------------------------------------------
create table tag_business
(
	id INTEGER not null                   -- id
		constraint tag_business_pk
			primary key autoincrement,
	key_id int,                           -- 域ID（Tag 或 Field ID）
	business_id int,                      -- 业务ID
	datatype_id int,                      -- 该域对于该业务，特别指定的数据类型的ID
	description text,                     -- 域对于该业务的意义
	remark text,                          -- 附加解释、备注等
	mode char                             -- 0 Binary 1 STEP，由于Binary是Field ID，
	                                      -- 而STEP是以Tag值作为主键，两个协议的域存在于不同的表之中
								          -- 可能会导致Field ID 与 Tag重复的情况，因此在tag_business中增加mode字段以标识
);

create unique index tag_business_id_uindex
	on tag_business (id);
--------------------------------------------------
-- Tag-Business
--------------------------------------------------


--------------------------------------------------
-- Config
-- ：配置表
--------------------------------------------------
create table config
(
	id INTEGER not null
		constraint config_pk
			primary key autoincrement,
	name text,
	value text
);

create unique index config_id_uindex
	on config (id);
--------------------------------------------------
-- Config
--------------------------------------------------

--------------------------------------------------
-- Log
-- ：日志
--------------------------------------------------
create table log
(
	id INTEGER not null
		constraint log_pk
			primary key autoincrement,
	time datetime,
	event text
);

create unique index log_id_uindex
	on log (id);
--------------------------------------------------
-- Log
--------------------------------------------------


--------------------------------------------------
-- Field
-- ：Binary域名
--------------------------------------------------
create table field
(
	id INTEGER not null
		constraint field_pk
			primary key autoincrement,
	name_en text,
	name_cn text,
	description_cn text,
	description_en text
);

create unique index field_id_uindex
	on field (id);
--------------------------------------------------
-- Field
--------------------------------------------------

--------------------------------------------------
-- DataType
-- ：数据类型
--------------------------------------------------
create table datatype
(
	id INTEGER not null -- 数据类型ID
		constraint datatype_pk
			primary key autoincrement,
	alias text,
	datatype text, -- 数据类型名称
    datalen int,
	remark text
);

create unique index datatype_id_uindex
	on datatype (id);
--------------------------------------------------
-- DataType
--------------------------------------------------

--------------------------------------------------
-- MessageType
-- ：消息类型
--------------------------------------------------
create table msgtype
(
	msgtype INTEGER not null    -- 消息类型ID
		constraint msgtype_pk
			primary key,
	name_en text,               -- Tag英文释义
	name_cn text,               -- Tag中文释义
	description_cn text,        -- 中文说明
	description_en text         -- 英文说明
);
create unique index msgtype_msgtype_uindex
	on msgtype (msgtype);

--------------------------------------------------
-- MessageType
--------------------------------------------------


--------------------------------------------------
-- MessageFormat
-- ：Binary消息格式
--------------------------------------------------
create table msgformat
(
	business_id INTEGER,
	msgtype INTEGER,
	bizid varchar(10),
	format text,
	constraint msgformat_pk
		primary key (business_id, msgtype_id, bizid)
);
--------------------------------------------------
-- MessageFormat
--------------------------------------------------


--------------------------------------------------
-- Message List
-- ：消息列表
--------------------------------------------------
create table msglist
(
	sno INTEGER,
	msgtype INTEGER,
	content_pro text,
	type int         -- 0 FIX 1 Binary
);
--------------------------------------------------
-- Message List
--------------------------------------------------

--------------------------------------------------
-- Binary Result List
-- ：单个Binary消息的解析结果
--------------------------------------------------
create table msgresult_binary
(
	field text,
	value text,
	meaning text,
	name text
);
--------------------------------------------------
-- Binary Result List
--------------------------------------------------

--------------------------------------------------
-- Binary Result List Batch
-- ：多个Binary消息的解析结果
--------------------------------------------------
create table msgresult_binary_bat
(
	sno int,
	field text,
	value text,
	meaning text,
	name text
);
--------------------------------------------------
-- Binary Result List Batch
--------------------------------------------------

--------------------------------------------------
-- FIX Result List Batch
-- ：多个FIX消息的解析结果
--------------------------------------------------
create table msgresult_fix_bat
(
	sno int,        -- 在消息列表中，该消息的索引值
    sequence int,   -- 在本消息中，该域的序号
	tag int,
	value text,
	meaning text,
	name_en text,
	name_cn text
);
--------------------------------------------------
-- FIX Result List Batch
--------------------------------------------------

--------------------------------------------------
-- FIX Result List Batch
-- ：目前展示中的FIX解析结果
--------------------------------------------------
create table msgresult_fix
(
    sequence int,   -- 在本消息中，该域的序号
	tag text,
	value text,
	meaning text,
	name_en text,
	name_cn text
);
--------------------------------------------------
-- FIX Result List Batch
--------------------------------------------------

--------------------------------------------------
-- Respond
-- ：回报规则
-- ：通过ApplID和MsgType可以唯一确定一个平台的业务，所以事先需要选择平台
--------------------------------------------------
create table respond
(
	id INTEGER not null                    -- 回报规则ID
		constraint respond_pk
			primary key autoincrement,
	business_id int,
	applid text,                           -- 应用标识
    name text,                             -- 回报类型: 全部成交、部分成交、撤单成功、确认失败、分笔成交、确认成功、撤单失败、部分撤单、废单
	rule text,                             -- 回报匹配规则
	format text,                           -- 回报格式
	mode char(1)                           -- 数据协议：0 FIX 1 Binary
);
--------------------------------------------------
-- Respond
--------------------------------------------------

--------------------------------------------------
-- Response
-- ：生成的回报
--------------------------------------------------
create table response
(
	sno int,
	tag text,
	value text,
	meaning text,
	name_en text,
	name_cn text
);
--------------------------------------------------
-- Response
--------------------------------------------------

--------------------------------------------------
-- Output Type
-- ：输出
-- ：输出格式设置
--------------------------------------------------
create table outputformat
(
	id INTEGER not null
		constraint outputformat_pk
			primary key autoincrement,
    name text,
	base64 int, -- 0 不进行Base64编码  1 进行Base64编码
	leftstring text,
	rightstring text
);
--------------------------------------------------
-- Output Type
--------------------------------------------------

--------------------------------------------------
-- Repeat
-- ：重复组规则
--------------------------------------------------
create table repeat
(
	business_id int,
	applid text,
	tag int,
	judgement text,
	meaning text,
	which int
);
--------------------------------------------------
-- Repeat
--------------------------------------------------

--------------------------------------------------
-- Other Business
-- ：其他业务
--------------------------------------------------
create table business_other
(
	id INTEGER not null                   -- 业务ID
		constraint business_pk
			primary key autoincrement,
	name text,                            -- 业务名称
	description text                      -- 业务说明
);

create unique index business_other_id_uindex
	on business_other (id);
--------------------------------------------------
-- Business
--------------------------------------------------

--------------------------------------------------
-- Column
-- ：栏
--------------------------------------------------
create table column
(
	business_id int,
	sequence int,
	name_r text, -- raw name
	name_c text, -- cooked name
	datatype text,
	datalength int,
	description text,
	constraint msgformat_pk
		primary key (business_id, sequence)
);
--------------------------------------------------
-- Repeat
--------------------------------------------------

