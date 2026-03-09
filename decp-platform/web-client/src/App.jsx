import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Register from './pages/Register';
import LoginPage from "./pages/LoginPage.jsx";
import FeedPage from "./pages/FeedPage.jsx";
import CareersPage from "./pages/CareersPage.jsx";
import ProfilePage from "./pages/ProfilePage.jsx";
import NetworkingPage from "./pages/NetworkingPage.jsx";

function App() {
    return (
        <BrowserRouter>
            <div className="App">
                <Navbar />

                <div className="container">
                    <Routes>
                        <Route path="/" element={
                            <div className="card" style={{ textAlign: 'center', marginTop: '50px' }}>
                                <img src="/logoNoBack.png" alt="DECP Logo" style={{ height: '120px', marginBottom: '20px' }} />
                                <h1>Welcome to UniConnect</h1>
                                <p style={{ fontSize: '1.2rem', color: 'var(--text-secondary)' }}>
                                    The Department Engagement & Career Platform for students, alumni, and administrators.
                                </p>
                            </div>
                        } />
                        <Route path="/login" element={<LoginPage />} />
                        <Route path="/register" element={<Register />} />
                        <Route path="/feed" element={<FeedPage />} />
                        <Route path="/careers" element={<CareersPage />} />
                        <Route path="/profile" element={<ProfilePage />} />
                        <Route path="/network" element={<NetworkingPage />} />
                    </Routes>
                </div>
            </div>
        </BrowserRouter>
    );
}

export default App;