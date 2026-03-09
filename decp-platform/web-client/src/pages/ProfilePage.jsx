import { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

export default function ProfilePage() {
    const [profile, setProfile] = useState(null);
    const [isEditing, setIsEditing] = useState(false);
    const [formData, setFormData] = useState({});
    const [error, setError] = useState('');
    const [message, setMessage] = useState('');
    const navigate = useNavigate();

    const currentUserId = localStorage.getItem('userId');

    useEffect(() => {
        const token = localStorage.getItem('token');
        if (!token) {
            navigate('/login');
            return;
        }
        fetchProfile();
    }, [navigate]);

    const fetchProfile = async () => {
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get(`/api/users/${currentUserId}/profile`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setProfile(response.data);
            setFormData({
                name: response.data.name || '',
                bio: response.data.bio || '',
                department: response.data.department || '',
                graduationYear: response.data.graduationYear || '',
                researchInterests: response.data.researchInterests || '[]',
                courseProjects: response.data.courseProjects || '[]'
            });
        } catch (err) {
            setError('Failed to load profile.');
        }
    };

    const handleUpdate = async (e) => {
        e.preventDefault();
        setError('');
        setMessage('');
        try {
            const token = localStorage.getItem('token');
            const response = await axios.put(`/api/users/${currentUserId}/profile`, formData, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setProfile(response.data);
            setIsEditing(false);
            setMessage('Profile updated successfully!');
            localStorage.setItem('userName', response.data.name);
        } catch (err) {
            setError('Failed to update profile.');
        }
    };

    if (!profile) return (
        <div className="main-layout" style={{ display: 'flex', justifyContent: 'center', marginTop: '100px' }}>
            <p style={{ color: 'var(--linkedin-text-secondary)' }}>Loading profile...</p>
        </div>
    );

    return (
        <div className="main-layout">
            <main>
                <div className="li-card" style={{ position: 'relative' }}>
                    <div style={{ height: '200px', background: 'var(--linkedin-blue)' }}></div>
                    <div style={{ padding: '0 24px 24px' }}>
                        <div style={{ width: '152px', height: '152px', borderRadius: '50%', border: '4px solid white', background: '#fff', position: 'relative', marginTop: '-112px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '64px', fontWeight: 'bold', color: 'var(--linkedin-blue)' }}>
                            {profile.name.charAt(0).toUpperCase()}
                        </div>
                        <div style={{ marginTop: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '16px' }}>
                            <div style={{ minWidth: '250px' }}>
                                <h1 style={{ fontSize: '24px', fontWeight: '600', marginBottom: '4px', color: 'var(--linkedin-text-primary)' }}>{profile.name}</h1>
                                <p style={{ fontSize: '16px', color: 'var(--linkedin-text-primary)', marginBottom: '4px' }}>{profile.department || 'Add department'}</p>
                                <p style={{ fontSize: '14px', color: 'var(--linkedin-text-secondary)' }}>University of Peradeniya • {profile.graduationYear || 'Add graduation year'}</p>
                                <div style={{ display: 'flex', gap: '15px', marginTop: '12px' }}>
                                    <span style={{ fontSize: '14px', color: 'var(--linkedin-blue)', fontWeight: '600' }}>{profile.connections} connections</span>
                                    <span style={{ fontSize: '14px', color: 'var(--linkedin-text-secondary)' }}>{profile.profileViews} profile views</span>
                                </div>
                            </div>
                            <div style={{ display: 'flex', gap: '8px' }}>
                                <button className="li-btn li-btn-primary">Open to</button>
                                <button className="li-btn li-btn-outline">Add profile section</button>
                                <button onClick={() => setIsEditing(true)} className="li-btn li-btn-ghost">Edit</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="li-card" style={{ padding: '24px' }}>
                    <h2 style={{ fontSize: '20px', fontWeight: '600', marginBottom: '16px', color: 'var(--linkedin-text-primary)' }}>About</h2>
                    <p style={{ fontSize: '14px', lineHeight: '1.5', color: 'var(--linkedin-text-primary)', whiteSpace: 'pre-wrap' }}>
                        {profile.bio || 'Add a summary to your profile to let people know about your interests and goals.'}
                    </p>
                </div>

                <div className="li-card" style={{ padding: '24px' }}>
                    <h2 style={{ fontSize: '20px', fontWeight: '600', marginBottom: '16px', color: 'var(--linkedin-text-primary)' }}>Education</h2>
                    <div style={{ display: 'flex', gap: '12px' }}>
                        <div style={{ width: '48px', height: '48px', background: 'var(--linkedin-bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px', fontWeight: 'bold', color: 'var(--linkedin-blue)' }}>UoP</div>
                        <div>
                            <div style={{ fontWeight: '600', fontSize: '16px' }}>University of Peradeniya</div>
                            <div style={{ fontSize: '14px' }}>{profile.department || 'Add department'}</div>
                            <div style={{ fontSize: '14px', color: 'var(--linkedin-text-secondary)', marginTop: '4px' }}>{profile.graduationYear ? `Expected Graduation: ${profile.graduationYear}` : 'Add graduation year'}</div>
                        </div>
                    </div>
                </div>

                {isEditing && (
                    <div style={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
                        <div className="li-card" style={{ width: '600px', padding: '24px', position: 'relative' }}>
                            <button onClick={() => setIsEditing(false)} style={{ position: 'absolute', right: '16px', top: '16px', background: 'none', border: 'none', fontSize: '20px', cursor: 'pointer' }}>&times;</button>
                            <h2 style={{ fontSize: '20px', fontWeight: '600', marginBottom: '24px' }}>Edit intro</h2>
                            <form onSubmit={handleUpdate} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                                <div>
                                    <label style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', display: 'block', marginBottom: '4px' }}>Name</label>
                                    <input type="text" className="li-input" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} required />
                                </div>
                                <div style={{ display: 'flex', gap: '12px' }}>
                                    <div style={{ flex: 1 }}>
                                        <label style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', display: 'block', marginBottom: '4px' }}>Department</label>
                                        <input type="text" className="li-input" value={formData.department} onChange={e => setFormData({...formData, department: e.target.value})} />
                                    </div>
                                    <div style={{ flex: 1 }}>
                                        <label style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', display: 'block', marginBottom: '4px' }}>Graduation Year</label>
                                        <input type="number" className="li-input" value={formData.graduationYear} onChange={e => setFormData({...formData, graduationYear: e.target.value})} />
                                    </div>
                                </div>
                                <div>
                                    <label style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', display: 'block', marginBottom: '4px' }}>Bio</label>
                                    <textarea rows="5" className="li-input" value={formData.bio} onChange={e => setFormData({...formData, bio: e.target.value})} />
                                </div>
                                <button type="submit" className="li-btn li-btn-primary" style={{ alignSelf: 'flex-end' }}>Save</button>
                            </form>
                        </div>
                    </div>
                )}
            </main>

            <aside className="sidebar-right">
                <div className="li-card" style={{ padding: '12px' }}>
                    <div style={{ fontWeight: '600', fontSize: '16px', marginBottom: '16px' }}>Public profile & URL</div>
                    <div style={{ fontSize: '14px', color: 'var(--linkedin-text-secondary)', marginBottom: '12px' }}>
                        www.uniconnect.com/in/{profile.name.toLowerCase().replace(/\s/g, '-')}
                    </div>
                    <button className="li-btn li-btn-ghost" style={{ fontSize: '14px', padding: '0' }}>Edit public profile & URL</button>
                </div>
            </aside>
        </div>
    );
}