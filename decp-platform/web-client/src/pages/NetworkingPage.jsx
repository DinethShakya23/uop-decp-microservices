import { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

export default function NetworkingPage() {
    const [users, setUsers] = useState([]);
    const [myConnections, setMyConnections] = useState([]);
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const currentUserId = localStorage.getItem('userId');

    useEffect(() => {
        const token = localStorage.getItem('token');
        if (!token) {
            navigate('/login');
            return;
        }
        fetchUsers();
    }, [navigate]);

    const fetchUsers = async () => {
        try {
            const token = localStorage.getItem('token');
            // For now, we'll need a way to list users. Let's assume an endpoint exists or we add one.
            // Since I haven't added a list users endpoint yet, I'll add it to user-service.
            const response = await axios.get('/api/users/list', {
                headers: { Authorization: `Bearer ${token}` }
            });
            // Filter out current user
            setUsers(response.data.filter(u => String(u.id) !== String(currentUserId)));
        } catch (err) {
            setError('Failed to load users.');
        }
    };

    const handleConnect = async (userId) => {
        const token = localStorage.getItem('token');
        try {
            await axios.post(`/api/users/${userId}/connect`, {}, {
                headers: { Authorization: `Bearer ${token}` }
            });
            alert("Connected successfully!");
            fetchUsers();
        } catch (err) {
            console.error(err);
        }
    };

    return (
        <div className="container" style={{ maxWidth: '900px' }}>
            <h2>My Network</h2>
            <div className="li-card" style={{ padding: '24px' }}>
                <div className="responsive-grid">
                    {users.map(user => (
                        <div key={user.id} className="li-card" style={{ textAlign: 'center', padding: '16px', border: '1px solid var(--linkedin-border)' }}>
                            <div style={{ width: '72px', height: '72px', background: 'var(--linkedin-bg)', borderRadius: '50%', margin: '0 auto 12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '24px', fontWeight: 'bold', color: 'var(--linkedin-blue)' }}>
                                {user.name.charAt(0).toUpperCase()}
                            </div>
                            <div style={{ fontWeight: '600', fontSize: '16px', marginBottom: '4px' }}>{user.name}</div>
                            <div style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', marginBottom: '16px', height: '32px', overflow: 'hidden' }}>{user.department || 'University of Peradeniya'}</div>
                            <button onClick={() => handleConnect(user.id)} className="li-btn li-btn-outline" style={{ width: '100%', fontSize: '14px' }}>Connect</button>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}