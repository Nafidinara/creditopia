import { useState } from 'react';
import { backend_mo } from 'declarations/backend_mo';
import { backend_azle } from '../../declarations/backend_azle';
import { backend_rust } from '../../declarations/backend_rust';

function App() {
  const [greeting, setGreeting] = useState('');
  const [makan, setMakan] = useState('');
  const [hobby, setHobby] = useState('');

  function handleSubmit(event) {
    event.preventDefault();
    const name = event.target.elements.name.value;
    backend_mo.greet(name).then((greeting) => {
      setGreeting(greeting);
    });
    return false;
  }

  function handleSubmit2(event) {
    event.preventDefault();
    const name = event.target.elements.name.value;
    backend_azle.makan(name).then((makan) => {
      setMakan(makan);
    });
    return false;
  }

  function handleSubmit3(event) {
    event.preventDefault();
    const name = event.target.elements.name.value;
    backend_rust.hobby(name).then((hobby) => {
      setHobby(hobby);
    });
    return false;
  }

  return (
    <main>
      <img src="/logo2.svg" alt="DFINITY logo" />
      <br />
      <br />
      <form action="#" onSubmit={handleSubmit}>
        <label htmlFor="name">Enter your name: &nbsp;</label>
        <input id="name" alt="Name" type="text" />
        <button type="submit">Click Me!</button>
      </form>
      <section id="greeting">{greeting}</section>

      <form action="#" onSubmit={handleSubmit2}>
        <label htmlFor="name">Mau makan apa?: &nbsp;</label>
        <input id="name" alt="Name" type="text" />
        <button type="submit">Click Me!</button>
      </form>
      <section id="greeting">{makan}</section>

      <form action="#" onSubmit={handleSubmit3}>
        <label htmlFor="name">What is your hobby?: &nbsp;</label>
        <input id="name" alt="Name" type="text" />
        <button type="submit">Click Me!</button>
      </form>
      <section id="greeting">{hobby}</section>
    </main>
  );
}

export default App;
