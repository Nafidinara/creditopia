import { HttpAgent, Actor } from '@dfinity/agent';
import { backend_mo } from '../../declarations/backend_mo';
import { Principal } from '@dfinity/principal';

const LOCAL_CANISTER_ID = "your-local-canister-id";

// Set up the agent to communicate with the local replica
const agent = new HttpAgent({ host: 'http://localhost:8000' });

// Create an actor for the canister
export const canisterActor = Actor.createActor(idlFactory, {
  agent,
  canisterId: LOCAL_CANISTER_ID,
});
