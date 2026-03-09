import { Link, useNavigate, useLocation } from 'react-router-dom';

export default function Navbar() {
    const navigate = useNavigate();
    const location = useLocation();
    const token = localStorage.getItem('token');
    const userName = localStorage.getItem('userName');

    const handleLogout = () => {
        localStorage.clear();
        navigate('/login');
    };

    const isActive = (path) => location.pathname === path ? 'nav-link active' : 'nav-link';

    return (
        <nav className="navbar">
            <div className="nav-content">
                <Link to="/" className="nav-logo">
                    in
                </Link>
                <div style={{ marginRight: 'auto', color: 'var(--linkedin-blue)', fontWeight: 'bold', fontSize: '18px' }}>
                    UniConnect
                </div>

                <div style={{ display: 'flex', height: '100%' }}>
                    <Link to="/" className={isActive('/')}>
                        <span className="nav-icon">🏠</span>
                        <span>Home</span>
                    </Link>
                    
                    {token ? (
                        <>
                            <Link to="/feed" className={isActive('/feed')}>
                                <span className="nav-icon">📰</span>
                                <span>Feed</span>
                            </Link>
                            <Link to="/network" className={isActive('/network')}>
                                <span className="nav-icon">👥</span>
                                <span>My Network</span>
                            </Link>
                            <Link to="/careers" className={isActive('/careers')}>
                                <span className="nav-icon">💼</span>
                                <span>Jobs</span>
                            </Link>
                            <Link to="/profile" className={isActive('/profile')}>
                                <span className="nav-icon">👤</span>
                                <span>Me</span>
                            </Link>
                            
                            <div style={{ marginLeft: '10px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <button onClick={handleLogout} className="li-btn li-btn-ghost" style={{ fontSize: '12px' }}>
                                    Logout
                                </button>
                            </div>
                        </>
                    ) : (
                        <>
                            <Link to="/login" className={isActive('/login')}>
                                <span className="nav-icon">🔑</span>
                                <span>Sign In</span>
                            </Link>
                            <Link to="/register" className={isActive('/register')}>
                                <span className="nav-icon">📝</span>
                                <span>Join Now</span>
                            </Link>
                        </>
                    )}
                </div>
            </div>
        </nav>
    );
}