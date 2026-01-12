import { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null); // Error check karne ke liye

  useEffect(() => {
    axios.get('http://backend:5000/api/data')
      .then(response => {
        setData(response.data);
      })
      .catch(err => {
        console.error(err);
        setError("Backend se connect nahi ho paya!");
      });
  }, []);

  return (
    <div className="container">
      <h1>My React App</h1>
      
      {error && <p style={{ color: 'red' }}>{error}</p>}

      {data ? (
        <pre>{JSON.stringify(data, null, 2)}</pre>
      ) : (
        !error && <p>Loading data from port 5000...</p>
      )}
    </div>
  );
}

export default App;