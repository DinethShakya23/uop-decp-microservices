import { useState } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';

export default function Register() {
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        password: '',
        role: 'STUDENT'
    });
    const [message, setMessage] = useState('');
    const [status, setStatus] = useState('');

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setMessage('');
        setStatus('');
        try {
            const response = await axios.post('/api/users/register', formData);
            setMessage(`Success! Welcome, ${response.data.name}. You can now login.`);
            setStatus('success');
            setFormData({ name: '', email: '', password: '', role: 'STUDENT' });
        } catch (error) {
            setStatus('error');
            if (error.response && typeof error.response.data === 'string') {
                setMessage(error.response.data);
            } else if (error.response && error.response.data.message) {
                setMessage(error.response.data.message);
            } else {
                setMessage("An error occurred. Is the service running?");
            }
        }
    };

    return (
        <div className="auth-container" style={{ padding: '24px 12px' }}>
            <div className="li-card" style={{ maxWidth: '450px', width: '100%', textAlign: 'center', padding: '24px' }}>
                <div style={{ color: 'var(--linkedin-blue)', fontSize: '32px', fontWeight: 'bold', marginBottom: '10px' }}>in</div>
                <h2>Join UniConnect</h2>
                <p style={{ color: 'var(--text-secondary)', marginBottom: '20px' }}>Join the community of students, alumni, and admins.</p>

                {message && (
                    <p style={{ 
                        backgroundColor: status === 'success' ? '#e7f8ed' : '#f8d7da',
                        color: status === 'success' ? '#2db84c' : '#dc3545',
                        padding: '12px',
                        borderRadius: '6px',
                        marginBottom: '20px',
                        fontWeight: 'bold'
                    }}>
                        {message}
                    </p>
                )}

                <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', textAlign: 'left' }}>
                    <div className="form-group">
                        <label className="label">Full Name</label>
                        <input type="text" name="name" className="input" placeholder="e.g. John Doe" required
                               onChange={handleChange} value={formData.name} />
                    </div>

                    <div className="form-group">
                        <label className="label">University Email</label>
                        <input type="email" name="email" className="input" placeholder="e.g. john@eng.pdn.ac.lk" required
                               onChange={handleChange} value={formData.email} />
                    </div>

                    <div className="form-group">
                        <label className="label">Password</label>
                        <input type="password" name="password" className="input" placeholder="Min 6 characters" required
                               onChange={handleChange} value={formData.password} />
                    </div>

                    <div className="form-group">
                        <label className="label">I am a...</label>
                        <select name="role" className="select" onChange={handleChange} value={formData.role}>
                            <option value="STUDENT">Student</option>
                            <option value="ALUMNI">Alumni</option>
                            <option value="ADMIN">Admin</option>
                        </select>
                    </div>

                    <button type="submit" className="btn btn-primary" style={{ marginTop: '10px' }}>
                        Create Account
                    </button>
                </form>

                <p style={{ marginTop: '20px', fontSize: '0.9rem' }}>
                    Already have an account? <Link to="/login" style={{ color: 'var(--primary-color)', fontWeight: 'bold' }}>Login Here</Link>
                </p>
            </div>
        </div>
    );
}