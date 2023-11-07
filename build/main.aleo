program zkpmarket.aleo;

record token:
    owner as address.private;
    amount as u64.private;

struct ClientConfig:
    addr as address;
    min_fee as u64;
    max_instance as u8;
    cur_instance as u8;

struct ProofTask:
    task_type as u8;
    block_id as u64;
    prover as address;
    expiry as u64;
    status as u8;
    actual_prover as address;
    fee as u64;


mapping balances:
	key as address.public;
	value as u64.public;


mapping clients:
	key as field.public;
	value as ClientConfig.public;


mapping tasks:
	key as field.public;
	value as ProofTask.public;

function mint_public:
    input r0 as address.public;
    input r1 as u64.public;
    cast r0 r1 into r2 as token.record;
    async mint_public r0 r1 into r3;
    output r2 as token.record;
    output r3 as zkpmarket.aleo/mint_public.future;

finalize mint_public:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use balances[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into balances[r0];


function approve:
    input r0 as address.private;
    input r1 as u64.private;
    input r2 as address.private;
    input r3 as u64.private;
    gte r1 r3 into r4;
    ternary r4 true false into r5;
    output r5 as boolean.private;


function transfer:
    input r0 as address.public;
    input r1 as u64.private;
    async transfer self.caller r0 r1 into r2;
    output true as boolean.private;
    output r2 as zkpmarket.aleo/transfer.future;

finalize transfer:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    get.or_use balances[r0] 0u64 into r3;
    gte r3 r2 into r4;
    get.or_use balances[r1] 0u64 into r5;
    sub r3 r2 into r6;
    set r6 into balances[r0];
    add r5 r2 into r7;
    set r7 into balances[r1];


function name:
    output 65u64 as u64.private;
    output 80u64 as u64.private;
    output 85u64 as u64.private;
    output 83u64 as u64.private;


function symbol:
    output 65u64 as u64.private;
    output 80u64 as u64.private;
    output 84u64 as u64.private;


function join_market:
    input r0 as u64.private;
    input r1 as u8.private;
    input r2 as u8.private;
    cast self.caller r0 r1 r2 into r3 as ClientConfig;
    async join_market r3 into r4;
    output true as boolean.private;
    output r4 as zkpmarket.aleo/join_market.future;

finalize join_market:
    input r0 as ClientConfig.public;
    rand.chacha into r1 as field;
    set r0 into clients[r1];


function get_lowest:
    cast self.caller 0u64 0u8 0u8 into r0 as ClientConfig;
    output r0 as ClientConfig.private;


function dispatch_task:
    input r0 as field.private;
    async dispatch_task r0 into r1;
    output true as boolean.private;
    output r1 as zkpmarket.aleo/dispatch_task.future;

finalize dispatch_task:
    input r0 as field.public;
    get clients[r0] into r1;
    lt r1.cur_instance r1.max_instance into r2;
    add r1.cur_instance 1u8 into r3;
    cast r1.addr r1.min_fee r1.max_instance r3 into r4 as ClientConfig;
    set r4 into clients[r0];


function release_task:
    input r0 as field.private;
    async release_task r0 into r1;
    output true as boolean.private;
    output r1 as zkpmarket.aleo/release_task.future;

finalize release_task:
    input r0 as field.public;
    get clients[r0] into r1;
    gt r1.cur_instance 0u8 into r2;
    sub r1.cur_instance 1u8 into r3;
    cast r1.addr r1.min_fee r1.max_instance r3 into r4 as ClientConfig;
    set r4 into clients[r0];


function get_client_config:
    input r0 as field.private;
    cast self.caller 0u64 0u8 0u8 into r1 as ClientConfig;
    output r1 as ClientConfig.private;


function create_task:
    input r0 as u8.private;
    input r1 as u64.private;
    input r2 as address.private;
    input r3 as u64.private;
    input r4 as u64.private;
    cast r0 r1 r2 r3 0u8 aleo1ezamst4pjgj9zfxqq0fwfj8a4cjuqndmasgata3hggzqygggnyfq6kmyd4 r4 into r5 as ProofTask;
    async create_task self.caller r5 into r6;
    output true as boolean.private;
    output r6 as zkpmarket.aleo/create_task.future;

finalize create_task:
    input r0 as address.public;
    input r1 as ProofTask.public;
    get.or_use balances[r0] 0u64 into r2;
    sub r2 r1.fee into r3;
    set r3 into balances[r0];
    rand.chacha into r4 as field;
    set r1 into tasks[r4];


function prove_task:
    input r0 as field.private;
    async prove_task r0 self.caller into r1;
    output true as boolean.private;
    output r1 as zkpmarket.aleo/prove_task.future;

finalize prove_task:
    input r0 as field.public;
    input r1 as address.public;
    get tasks[r0] into r2;
    get.or_use balances[r1] 0u64 into r3;
    add r3 r2.fee into r4;
    set r4 into balances[r1];
    cast r2.task_type r2.block_id r2.prover r2.expiry 1u8 r1 r2.fee into r5 as ProofTask;
    set r5 into tasks[r0];
