import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 5000;

app.use(cors());
app.use(express.json()); // JSON data handle karne ke liye

app.get('/api/data', (req, res) => {
    res.json({ 
        message: "Hello from ES6 Node.js!", 
        status: "Success" 
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Server running at http://localhost:${PORT}`);
});