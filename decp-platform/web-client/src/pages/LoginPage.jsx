import { useState } from 'react';
import axios from 'axios';
import { useNavigate, Link } from 'react-router-dom';

export default function LoginPage() {
    const [credentials, setCredentials] = useState({ email: '', password: '' });
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const handleChange = (e) => {
        setCredentials({ ...credentials, [e.target.name]: e.target.value });
    };

    const handleLogin = async (e) => {
        e.preventDefault();
        try {
            const response = await axios.post('/api/users/login', credentials);
            localStorage.setItem('token', response.data.token);
            localStorage.setItem('role', response.data.role);
            localStorage.setItem('userId', response.data.id);
            localStorage.setItem('userName', response.data.name);
            navigate('/feed');
        } catch (err) {
            setError('Invalid email or password. Please try again.');
        }
    };

    return (
        <div className="auth-container" style={{ padding: '0 12px' }}>
            <div className="li-card" style={{ maxWidth: '400px', width: '100%', textAlign: 'center', padding: '24px' }}>
                <div style={{ color: 'var(--linkedin-blue)', fontSize: '32px', fontWeight: 'bold', marginBottom: '10px' }}>in</div>
                <h2>Welcome Back</h2>
                <p style={{ color: 'var(--text-secondary)', marginBottom: '20px' }}>Sign in to continue to UniConnect</p>
                
                {error && <p style={{ color: 'var(--danger-color)', marginBottom: '15px' }}>{error}</p>}
                
                <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', textAlign: 'left' }}>
                    <div className="form-group">
                        <label className="label">University Email</label>
                        <input type="email" name="email" className="input" placeholder="e.g. name@eng.pdn.ac.lk" required
                               onChange={handleChange} value={credentials.email} />
                    </div>

                    <div className="form-group">
                        <label className="label">Password</label>
                        <input type="password" name="password" className="input" placeholder="Enter your password" required
                               onChange={handleChange} value={credentials.password} />
                    </div>

                    <button type="submit" className="btn btn-primary" style={{ marginTop: '10px' }}>
                        Login
                    </button>
                </form>
                
                <p style={{ marginTop: '20px', fontSize: '0.9rem' }}>
                    New to DECP? <Link to="/register" style={{ color: 'var(--primary-color)', fontWeight: 'bold' }}>Create Account</Link>
                </p>
            </div>
        </div>
    );
}