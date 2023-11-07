// The 'zkpmarket' program.
program zkpmarket.aleo {
    record token {
        owner: address,
        amount: u64,
    }

    mapping balances: address => u64;


    transition mint_public(
        public receiver: address,
        public amount: u64,
    ) -> token {
        return token {
            owner: receiver,
            amount,
        } then finalize(receiver, amount);
    }

    finalize mint_public(
        public receiver: address,
        public amount: u64,
    ) {
        let current_amount: u64 = Mapping::get_or_use(balances, receiver, 0u64);
        Mapping::set(balances, receiver, current_amount + amount);
   }

    transition approve(owner: address, amount_owner: u64, spender: address, amount_desired : u64 )-> bool {
        let response_approve:bool = false;
        if amount_owner >= amount_desired {
            response_approve = true;
        }
        return response_approve;
    }

    transition transfer(public to: address, amount: u64) -> bool {
        return true then finalize(self.caller, to, amount);
    }

    finalize transfer (from:address, to: address, amount: u64) {
        let fromAccount: u64 = Mapping::get_or_use(balances, from, 0u64);
        if fromAccount >= amount {
            let toAccount: u64 = Mapping::get_or_use(balances, to, 0u64);
            Mapping::set(balances, from, fromAccount - amount);
            Mapping::set(balances, to, toAccount + amount);
        }
    }

    // Return four letters 'A' 'P' 'U' 'S' in ascii mode.
    // The parameter `is_dummmy` only exists for syntax purposes.
    transition name() -> (u64,u64,u64,u64) {
        let letter_A: u64 = 65u64;
        let letter_P: u64 = 80u64;
        let letter_U: u64 = 85u64;
        let letter_S: u64 = 83u64;
        return (letter_A, letter_P, letter_U, letter_S) ;
    }

    // Return four letters 'A' 'P' 'T' in ascii mode.
    // The parameter `is_dummmy` only exists for syntax purposes.
    transition symbol() -> (u64,u64,u64) {
        let letter_A: u64 = 65u64;
        let letter_P: u64 = 80u64;
        let letter_T: u64 = 84u64;
        return (letter_A, letter_P, letter_T);
    }

    struct ClientConfig {
        addr: address,
        min_fee: u64,
        // urls: [u8; 1024];
        max_instance: u8,
        cur_instance: u8,
    }

    mapping clients: field => ClientConfig;

    transition join_market(min_fee: u64, max_instance: u8, cur_instance:u8) -> bool {
        let clientConfig: ClientConfig = ClientConfig {
            addr: self.caller,
            min_fee: min_fee,
            // urls: urls,
            max_instance: max_instance,
            cur_instance: cur_instance,
        };
        return true then finalize(clientConfig);
    }

    finalize join_market(cfg: ClientConfig) {
        // clientLength = clientLength + 1u64;
        let clientId: field = ChaCha::rand_field();
        Mapping::set(clients, clientId, cfg);
    }

    transition get_lowest() -> ClientConfig {
        // TODO
        return ClientConfig {
            addr: self.caller,
            min_fee: 0u64,
            // urls: [0u8; 1024],
            max_instance: 0u8,
            cur_instance: 0u8,
        };
    }

    transition dispatch_task(clientId: field) -> bool {
        return true then finalize(clientId);
    }

    finalize dispatch_task(clientId: field) {
        let clientConfig: ClientConfig = Mapping::get(clients, clientId);
        let min_fee: u64 = clientConfig.min_fee;
        let max_instance: u8 = clientConfig.max_instance;
        let cur_instance: u8 = clientConfig.cur_instance;
        if cur_instance < max_instance {
            let new_instance: u8 = cur_instance + 1u8;
            let new_clientConfig: ClientConfig = ClientConfig {
                addr: clientConfig.addr,
                min_fee: min_fee,
                max_instance: max_instance,
                cur_instance: new_instance,
            };
            Mapping::set(clients, clientId, new_clientConfig);
        }
    }

    transition release_task(client_id: field) -> bool {
        return true then finalize(client_id);
    }

    finalize release_task(client_id: field) {
        let clientConfig: ClientConfig = Mapping::get(clients, client_id);
        let min_fee: u64 = clientConfig.min_fee;
        let max_instance: u8 = clientConfig.max_instance;
        let cur_instance: u8 = clientConfig.cur_instance;
        if cur_instance > 0u8 {
            let new_instance: u8 = cur_instance - 1u8;
            let new_clientConfig: ClientConfig = ClientConfig {
                addr: clientConfig.addr,
                min_fee: min_fee,
                max_instance: max_instance,
                cur_instance: new_instance,
            };
            Mapping::set(clients, client_id, new_clientConfig);
        }
    }

    transition get_client_config(client_id: field) -> ClientConfig {
        return ClientConfig {
            addr: self.caller,
            min_fee: 0u64,
            max_instance: 0u8,
            cur_instance: 0u8,
        };
    }

    struct ProofTask {
        task_type: u8, // 0: taiko, 1: scroll, 2: zkera
        block_id: u64,
        // meta: [u64; 8],
        prover: address,
        expiry: u64,
        status: u8, // 0: pending, 1: success, 2: failed
        actual_prover: address,
        fee: u64,
    }

    mapping tasks: field => ProofTask;

    transition create_task(task_type: u8, block_id: u64, prover: address, expiry: u64, fee: u64) -> bool {
        let task: ProofTask = ProofTask {
            task_type: task_type,
            block_id: block_id,
            prover: prover,
            expiry: expiry,
            status: 0u8,
            actual_prover: aleo1ezamst4pjgj9zfxqq0fwfj8a4cjuqndmasgata3hggzqygggnyfq6kmyd4,
            fee: fee,
        };
        return true then finalize(self.caller, task);
    }

    finalize create_task(addr: address, task: ProofTask) {
        // stake 10 token from addr
        let current_amount: u64 = Mapping::get_or_use(balances, addr, 0u64);
        Mapping::set(balances, addr, current_amount - task.fee);
        let taskId: field = ChaCha::rand_field();
        Mapping::set(tasks, taskId, task);
    }

    transition prove_task(task_id: field) -> bool {
        return true then finalize(task_id, self.caller);
    }

    finalize prove_task(task_id: field, actual_prover: address) {
        let task: ProofTask = Mapping::get(tasks, task_id);
        let prover: address = task.prover;
        let fee: u64 = task.fee;
        let current_amount: u64 = Mapping::get_or_use(balances, actual_prover, 0u64);
        Mapping::set(balances, actual_prover, current_amount + fee);
        let new_task: ProofTask = ProofTask {
            task_type: task.task_type,
            block_id: task.block_id,
            prover: prover,
            expiry: task.expiry,
            status: 1u8,
            actual_prover: actual_prover,
            fee: fee,
        };
        Mapping::set(tasks, task_id, new_task);
    }
}
