import { Link, useNavigate } from 'react-router-dom';

export default function Navbar() {
    const navigate = useNavigate();

    // Check if the user is currently logged in
    const token = localStorage.getItem('token');

    const handleLogout = () => {
        // 1. Destroy the VIP pass and user data
        localStorage.removeItem('token');
        localStorage.removeItem('role');
        localStorage.removeItem('userId');
        localStorage.removeItem('userName');

        // 2. Kick them back to the login screen
        navigate('/login');
    };

    return (
        <nav style={{
            display: 'flex',
            gap: '15px',
            padding: '15px',
            backgroundColor: '#f4f4f4',
            borderBottom: '1px solid #ddd',
            alignItems: 'center'
        }}>
            <strong style={{ marginRight: 'auto', fontSize: '1.2em' }}>DECP</strong>

            <Link to="/" style={{ textDecoration: 'none', color: '#333' }}>Home</Link>

            {/* Conditional Rendering: Show different links based on login status */}
            {token ? (
                <>
                    <Link to="/feed" style={{ textDecoration: 'none', color: '#333' }}>Feed</Link>

                    {/* --- NEW CAREERS LINK --- */}
                    <Link to="/careers" style={{ textDecoration: 'none', color: '#333' }}>Careers</Link>

                    <button
                        onClick={handleLogout}
                        style={{
                            padding: '5px 10px',
                            cursor: 'pointer',
                            backgroundColor: '#dc3545',
                            color: 'white',
                            border: 'none',
                            borderRadius: '4px'
                        }}
                    >
                        Logout
                    </button>
                </>
            ) : (
                <>
                    <Link to="/login" style={{ textDecoration: 'none', color: '#333' }}>Login</Link>
                    <Link to="/register" style={{ textDecoration: 'none', color: '#333' }}>Register</Link>
                </>
            )}
        </nav>
    );
}