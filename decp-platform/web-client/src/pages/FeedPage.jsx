import { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const CommentItem = ({ post, comment, currentUserId, onRefresh, depth = 0 }) => {
    const [isReplying, setIsReplying] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [replyText, setReplyText] = useState('');
    const [editText, setEditText] = useState(comment.text);
    const [showReplies, setShowReplies] = useState(true);

    const handleReply = async () => {
        if (!replyText.trim()) return;
        const token = localStorage.getItem('token');
        try {
            await axios.post(`/api/posts/${post.id}/comments/${comment.id}/replies`, { text: replyText }, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setReplyText('');
            setIsReplying(false);
            onRefresh();
        } catch (err) { console.error(err); }
    };

    const handleEdit = async () => {
        if (!editText.trim()) return;
        const token = localStorage.getItem('token');
        try {
            await axios.put(`/api/posts/${post.id}/comments/${comment.id}`, { text: editText }, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setIsEditing(false);
            onRefresh();
        } catch (err) { console.error(err); }
    };

    const handleDelete = async () => {
        if (!window.confirm("Delete this comment?")) return;
        const token = localStorage.getItem('token');
        try {
            await axios.delete(`/api/posts/${post.id}/comments/${comment.id}`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            onRefresh();
        } catch (err) { console.error(err); }
    };

    return (
        <div style={{ marginLeft: depth > 0 ? '20px' : '0', borderLeft: depth > 0 ? '2px solid var(--linkedin-border)' : 'none', paddingLeft: depth > 0 ? '10px' : '0', marginTop: '10px' }}>
            <div style={{ backgroundColor: '#f3f2ef', padding: '10px', borderRadius: '8px', position: 'relative' }}>
                <div style={{ fontWeight: '600', fontSize: '13px' }}>{comment.userName}</div>
                
                {isEditing ? (
                    <div style={{ marginTop: '5px' }}>
                        <textarea className="li-input" value={editText} onChange={(e) => setEditText(e.target.value)} style={{ padding: '5px', fontSize: '13px' }} />
                        <div style={{ display: 'flex', gap: '5px', marginTop: '5px' }}>
                            <button onClick={handleEdit} className="li-btn li-btn-primary" style={{ padding: '2px 8px', fontSize: '12px' }}>Save</button>
                            <button onClick={() => setIsEditing(false)} className="li-btn li-btn-ghost" style={{ padding: '2px 8px', fontSize: '12px' }}>Cancel</button>
                        </div>
                    </div>
                ) : (
                    <>
                        <div style={{ fontSize: '13px', marginTop: '2px' }}>{comment.text}</div>
                        <div style={{ display: 'flex', gap: '15px', marginTop: '5px', fontSize: '11px', color: 'var(--linkedin-text-secondary)' }}>
                            <span>{new Date(comment.createdAt).toLocaleString()}</span>
                            <button onClick={() => setIsReplying(!isReplying)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--linkedin-blue)', fontWeight: 'bold' }}>Reply</button>
                            {String(comment.userId) === String(currentUserId) && (
                                <>
                                    <button onClick={() => setIsEditing(true)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>Edit</button>
                                    <button onClick={handleDelete} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#dc3545' }}>Delete</button>
                                </>
                            )}
                        </div>
                    </>
                )}
            </div>

            {isReplying && (
                <div style={{ marginTop: '5px', marginLeft: '20px' }}>
                    <input type="text" className="li-input" placeholder="Write a reply..." value={replyText} onChange={(e) => setReplyText(e.target.value)} style={{ padding: '5px 10px', borderRadius: '15px', fontSize: '13px' }} />
                    <div style={{ display: 'flex', gap: '5px', marginTop: '5px' }}>
                        <button onClick={handleReply} className="li-btn li-btn-primary" style={{ padding: '2px 10px', fontSize: '12px' }}>Send</button>
                        <button onClick={() => setIsReplying(false)} className="li-btn li-btn-ghost" style={{ padding: '2px 10px', fontSize: '12px' }}>Cancel</button>
                    </div>
                </div>
            )}

            {comment.replies && comment.replies.length > 0 && (
                <>
                    <button onClick={() => setShowReplies(!showReplies)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--linkedin-text-secondary)', fontSize: '11px', marginTop: '5px', marginLeft: '20px' }}>
                        {showReplies ? 'Hide' : 'Show'} {comment.replies.length} {comment.replies.length === 1 ? 'reply' : 'replies'}
                    </button>
                    {showReplies && comment.replies.map(reply => (
                        <CommentItem key={reply.id} post={post} comment={reply} currentUserId={currentUserId} onRefresh={onRefresh} depth={depth + 1} />
                    ))}
                </>
            )}
        </div>
    );
};

export default function FeedPage() {
    const [posts, setPosts] = useState([]);
    const [stats, setStats] = useState({ profileViews: 0, connections: 0 });
    const [newPostContent, setNewPostContent] = useState('');
    const [error, setError] = useState('');
    const [commentTexts, setCommentTexts] = useState({});
    const [expandedComments, setExpandedComments] = useState({});
    const navigate = useNavigate();

    const currentUserId = localStorage.getItem('userId');
    const userName = localStorage.getItem('userName');
    const role = localStorage.getItem('role');

    useEffect(() => {
        const token = localStorage.getItem('token');
        if (!token) {
            navigate('/login');
            return;
        }
        fetchPosts().catch(err => console.error('Failed to fetch posts:', err));
        fetchStats();
    }, [navigate]);

    const fetchPosts = async () => {
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get('/api/posts/feed', {
                headers: { Authorization: `Bearer ${token}` }
            });
            const sortedPosts = response.data.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
            setPosts(sortedPosts);
        } catch (err) {
            setError('Failed to load the feed.');
            console.error(err);
        }
    };

    const fetchStats = async () => {
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get(`/api/users/${currentUserId}/profile`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setStats({
                profileViews: response.data.profileViews,
                connections: response.data.connections
            });
        } catch (err) { console.error('Failed to fetch stats'); }
    };

    const handleCreatePost = async (e) => {
        e.preventDefault();
        if (!newPostContent.trim()) return;
        const token = localStorage.getItem('token');
        try {
            await axios.post('/api/posts', { text: newPostContent }, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setNewPostContent('');
            fetchPosts();
        } catch (err) { setError("Failed to publish post."); }
    };

    const handleDeletePost = async (postId) => {
        if (!window.confirm("Are you sure?")) return;
        const token = localStorage.getItem('token');
        try {
            await axios.delete(`/api/posts/${postId}`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            fetchPosts();
        } catch (err) { setError("Failed to delete post."); }
    };

    const handleToggleLike = async (postId) => {
        const token = localStorage.getItem('token');
        try {
            await axios.post(`/api/posts/${postId}/likes`, {}, {
                headers: { Authorization: `Bearer ${token}` }
            });
            fetchPosts();
        } catch (err) { console.error(err); }
    };

    const handleAddComment = async (postId) => {
        const text = commentTexts[postId];
        if (!text || !text.trim()) return;
        const token = localStorage.getItem('token');
        try {
            await axios.post(`/api/posts/${postId}/comments`, { text }, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setCommentTexts({ ...commentTexts, [postId]: '' });
            fetchPosts();
        } catch (err) { console.error(err); }
    };

    return (
        <div className="main-layout">
            {/* Left Sidebar */}
            <aside className="sidebar-left">
                <div className="li-card" style={{ textAlign: 'center' }}>
                    <div style={{ height: '54px', background: 'var(--linkedin-blue)', marginBottom: '-32px' }}></div>
                    <div style={{ width: '64px', height: '64px', background: '#fff', borderRadius: '50%', border: '2px solid white', margin: '0 auto 12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '24px', fontWeight: 'bold', color: 'var(--linkedin-blue)', position: 'relative', zIndex: 1 }}>
                        {userName ? userName.charAt(0).toUpperCase() : '?'}
                    </div>
                    <div style={{ padding: '12px' }}>
                        <div style={{ fontWeight: '600', fontSize: '16px' }}>{userName}</div>
                        <div style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', marginTop: '4px' }}>{role}</div>
                    </div>
                    <div style={{ borderTop: '1px solid var(--linkedin-border)', padding: '12px', textAlign: 'left', fontSize: '12px' }}>
                        <div style={{ color: 'var(--linkedin-text-secondary)' }}>Profile viewers</div>
                        <div style={{ fontWeight: '600', color: 'var(--linkedin-blue)', float: 'right' }}>{stats.profileViews}</div>
                        <div style={{ clear: 'both', marginTop: '8px' }}>Connections</div>
                        <div style={{ fontWeight: '600', color: 'var(--linkedin-blue)', float: 'right' }}>{stats.connections}</div>
                        <div style={{ clear: 'both' }}></div>
                    </div>
                </div>
                <div className="li-card" style={{ padding: '12px', fontSize: '12px' }}>
                    <div style={{ fontWeight: '600', marginBottom: '8px' }}>Recent</div>
                    <div style={{ color: 'var(--linkedin-text-secondary)', marginBottom: '4px' }}># ComputerEngineering</div>
                    <div style={{ color: 'var(--linkedin-text-secondary)', marginBottom: '4px' }}># CareerPath</div>
                    <div style={{ color: 'var(--linkedin-text-secondary)', marginBottom: '4px' }}># PeradeniyaUni</div>
                </div>
            </aside>

            {/* Main Content */}
            <main>
                <div className="li-card" style={{ padding: '12px 16px' }}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                        <div style={{ width: '48px', height: '48px', borderRadius: '50%', background: 'var(--linkedin-bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', color: 'var(--linkedin-blue)' }}>
                            {userName ? userName.charAt(0).toUpperCase() : '?'}
                        </div>
                        <button 
                            onClick={() => document.getElementById('post-textarea').focus()}
                            style={{ flex: 1, textAlign: 'left', padding: '12px 16px', borderRadius: '35px', border: '1px solid var(--linkedin-border)', background: 'transparent', color: 'var(--linkedin-text-secondary)', cursor: 'text', fontSize: '14px', fontWeight: '600' }}
                        >
                            Start a post
                        </button>
                    </div>
                    <div style={{ marginTop: '12px' }}>
                        <textarea 
                            id="post-textarea"
                            className="li-input" 
                            rows="4" 
                            placeholder="What do you want to talk about?" 
                            value={newPostContent} 
                            onChange={(e) => setNewPostContent(e.target.value)}
                            style={{ border: 'none', background: 'transparent', padding: '0', marginBottom: '12px' }}
                        />
                        {newPostContent.trim() && (
                            <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
                                <button onClick={handleCreatePost} className="li-btn li-btn-primary">Post</button>
                            </div>
                        )}
                    </div>
                </div>

                {error && <p style={{ color: '#dc3545', margin: '10px 0' }}>{error}</p>}

                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    {posts.map((post) => (
                        <div key={post.id} className="li-card feed-post">
                            <div className="post-header">
                                <div style={{ width: '48px', height: '48px', borderRadius: '50%', background: 'var(--linkedin-bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', color: 'var(--linkedin-blue)', marginRight: '8px' }}>
                                    {post.authorName ? post.authorName.charAt(0).toUpperCase() : '?'}
                                </div>
                                <div className="post-meta">
                                    <span className="author-name">{post.authorName}</span>
                                    <span className="post-time">{new Date(post.createdAt).toLocaleDateString()} • 🌐</span>
                                </div>
                                {String(post.authorId) === String(currentUserId) && (
                                    <button onClick={() => handleDeletePost(post.id)} className="li-btn li-btn-ghost" style={{ marginLeft: 'auto', fontSize: '12px' }}>Delete</button>
                                )}
                            </div>
                            <div className="post-content">{post.text}</div>
                            <div style={{ paddingBottom: '4px', fontSize: '12px', color: 'var(--linkedin-text-secondary)', display: 'flex', gap: '8px' }}>
                                <span>👍 {post.likes ? post.likes.length : 0}</span>
                                <span>• {post.comments ? post.comments.length : 0} comments</span>
                            </div>
                            <div className="post-actions">
                                <button 
                                    onClick={() => handleToggleLike(post.id)} 
                                    className="li-btn li-btn-ghost" 
                                    style={{ flex: 1, color: post.likes && post.likes.includes(Number(currentUserId)) ? 'var(--linkedin-blue)' : 'inherit' }}
                                >
                                    {post.likes && post.likes.includes(Number(currentUserId)) ? '❤️ Like' : '👍 Like'}
                                </button>
                                <button onClick={() => setExpandedComments({ ...expandedComments, [post.id]: !expandedComments[post.id] })} className="li-btn li-btn-ghost" style={{ flex: 1 }}>
                                    💬 Comment
                                </button>
                                <button className="li-btn li-btn-ghost" style={{ flex: 1 }}>↗️ Repost</button>
                                <button className="li-btn li-btn-ghost" style={{ flex: 1 }}>📤 Send</button>
                            </div>

                            {expandedComments[post.id] && (
                                <div style={{ padding: '8px 16px 16px' }}>
                                    <div style={{ display: 'flex', gap: '8px', marginBottom: '12px' }}>
                                        <div style={{ width: '32px', height: '32px', borderRadius: '50%', background: 'var(--linkedin-bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', color: 'var(--linkedin-blue)', fontSize: '12px' }}>
                                            {userName ? userName.charAt(0).toUpperCase() : '?'}
                                        </div>
                                        <div style={{ flex: 1, position: 'relative' }}>
                                            <input 
                                                type="text" 
                                                className="li-input" 
                                                placeholder="Add a comment..." 
                                                value={commentTexts[post.id] || ''} 
                                                onChange={(e) => setCommentTexts({ ...commentTexts, [post.id]: e.target.value })}
                                                style={{ borderRadius: '24px' }}
                                            />
                                            {commentTexts[post.id] && (
                                                <button onClick={() => handleAddComment(post.id)} className="li-btn li-btn-primary" style={{ position: 'absolute', right: '4px', top: '4px', padding: '4px 12px', fontSize: '12px' }}>Post</button>
                                            )}
                                        </div>
                                    </div>
                                    {post.comments && post.comments.map(comment => (
                                        <CommentItem key={comment.id} post={post} comment={comment} currentUserId={currentUserId} onRefresh={fetchPosts} />
                                    ))}
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            </main>

            {/* Right Sidebar */}
            <aside className="sidebar-right">
                <div className="li-card" style={{ padding: '12px' }}>
                    <div style={{ fontWeight: '600', fontSize: '16px', marginBottom: '12px' }}>UniConnect News</div>
                    <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
                        <li style={{ marginBottom: '12px' }}>
                            <div style={{ fontSize: '14px', fontWeight: '600' }}>CO528 Project Showcase</div>
                            <div style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)' }}>2d ago • 456 readers</div>
                        </li>
                        <li style={{ marginBottom: '12px' }}>
                            <div style={{ fontSize: '14px', fontWeight: '600' }}>New Alumni Job Postings</div>
                            <div style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)' }}>5h ago • 1,234 readers</div>
                        </li>
                    </ul>
                </div>
                <div className="li-card" style={{ padding: '12px', textAlign: 'center' }}>
                    <p style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)' }}>Get the latest insights</p>
                    <div style={{ fontWeight: '600', marginBottom: '12px' }}>Follow UniConnect on Mobile</div>
                    <button className="li-btn li-btn-outline">Download App</button>
                </div>
            </aside>
        </div>
    );
}