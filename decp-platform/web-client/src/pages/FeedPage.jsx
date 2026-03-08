import { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

export default function FeedPage() {
    const [posts, setPosts] = useState([]);
    const [newPostContent, setNewPostContent] = useState('');
    const [error, setError] = useState('');
    const navigate = useNavigate();

    // Grab the currently logged-in user's ID to check ownership of posts
    const currentUserId = localStorage.getItem('userId');

    useEffect(() => {
        const token = localStorage.getItem('token');
        if (!token) {
            navigate('/login');
            return;
        }
        fetchPosts().catch(err => console.error('Failed to fetch posts:', err));
    }, [navigate]);

    const fetchPosts = async () => {
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get('http://localhost:8080/api/feed', {
                headers: { Authorization: `Bearer ${token}` }
            });

            const sortedPosts = response.data.sort((a, b) =>
                new Date(b.createdAt) - new Date(a.createdAt)
            );
            setPosts(sortedPosts);
        } catch (err) {
            setError('Failed to load the feed. Is the Gateway running?');
            console.error(err);
        }
    };

    const handleCreatePost = async (e) => {
        e.preventDefault();
        if (!newPostContent.trim()) return;

        const authorName = localStorage.getItem('userName');
        const token = localStorage.getItem('token');

        try {
            await axios.post('http://localhost:8080/api/feed', {
                authorId: currentUserId,
                authorName: authorName,
                content: newPostContent
            }, {
                headers: { Authorization: `Bearer ${token}` }
            });

            setNewPostContent('');
            fetchPosts();
        } catch (err) {
            console.error("Failed to create post", err);
            setError("Failed to publish post.");
        }
    };

    // --- NEW DELETE FUNCTION ---
    const handleDeletePost = async (postId) => {
        // Add a quick confirmation dialog so users don't accidentally click it
        if (!window.confirm("Are you sure you want to delete this post?")) return;

        const token = localStorage.getItem('token');
        try {
            await axios.delete(`http://localhost:8080/api/feed/${postId}`, {
                headers: { Authorization: `Bearer ${token}` }
            });

            fetchPosts(); // Refresh the feed immediately after deleting
        } catch (err) {
            console.error("Failed to delete post", err);
            setError("Failed to delete post. Does the backend endpoint exist?");
        }
    };

    return (
        <div style={{ padding: '20px', maxWidth: '600px', margin: '0 auto' }}>
            <h2>Department Feed</h2>
            {error && <p style={{ color: 'red' }}>{error}</p>}

            <form onSubmit={handleCreatePost} style={{ marginBottom: '30px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <textarea
                    rows="4"
                    placeholder="What's happening in the department?"
                    value={newPostContent}
                    onChange={(e) => setNewPostContent(e.target.value)}
                    style={{ padding: '10px', borderRadius: '5px', border: '1px solid #ccc', resize: 'vertical' }}
                />
                <button type="submit" style={{ padding: '10px', cursor: 'pointer', backgroundColor: '#0056b3', color: 'white', border: 'none', borderRadius: '5px' }}>
                    Post Announcement
                </button>
            </form>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
                {posts.length === 0 ? (
                    <p>No posts yet. It is pretty quiet in here!</p>
                ) : (
                    posts.map((post) => (
                        <div key={post.id} style={{
                            border: '1px solid #ccc', padding: '15px', borderRadius: '8px', backgroundColor: '#f9f9f9', position: 'relative'
                        }}>

                            {/* --- CONDITIONAL DELETE BUTTON --- */}
                            {String(post.authorId) === String(currentUserId) && (
                                <button
                                    onClick={() => handleDeletePost(post.id)}
                                    style={{
                                        position: 'absolute', top: '15px', right: '15px',
                                        backgroundColor: '#dc3545', color: 'white', border: 'none',
                                        borderRadius: '4px', padding: '5px 10px', cursor: 'pointer'
                                    }}
                                >
                                    Delete
                                </button>
                            )}

                            <div style={{ fontWeight: 'bold', marginBottom: '8px', paddingRight: '60px' }}>
                                {post.authorName}
                                <span style={{ color: '#777', fontSize: '0.85em', marginLeft: '10px' }}>
                                    {new Date(post.createdAt).toLocaleString()}
                                </span>
                            </div>
                            <div style={{ fontSize: '1.1em', lineHeight: '1.4' }}>
                                {post.content}
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}