import { Canister, query, text } from 'azle';

export default Canister({
    makan: query([text], text, (name) => {
        return `Aku mau makan, ${name}!`;
    })
})
