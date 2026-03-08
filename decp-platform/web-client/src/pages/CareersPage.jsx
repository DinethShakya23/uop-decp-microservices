import { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

export default function CareersPage() {
    const [jobs, setJobs] = useState([]);
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const currentUserId = localStorage.getItem('userId');

    // Form state for a new job
    const [newJob, setNewJob] = useState({
        title: '',
        company: '',
        description: '',
        location: '',
        employmentType: 'Full-Time',
        applyLink: ''
    });

    useEffect(() => {
        const token = localStorage.getItem('token');
        if (!token) {
            navigate('/login');
            return;
        }
        fetchJobs();
    }, [navigate]);

    const fetchJobs = async () => {
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get('http://localhost:8080/api/careers', {
                headers: { Authorization: `Bearer ${token}` }
            });
            setJobs(response.data);
        } catch (err) {
            setError('Failed to load careers. Is the Gateway running?');
            console.error(err);
        }
    };

    const handleCreateJob = async (e) => {
        e.preventDefault();
        const authorName = localStorage.getItem('userName');
        const token = localStorage.getItem('token');

        try {
            await axios.post('http://localhost:8080/api/careers', {
                ...newJob,
                postedByUserId: currentUserId,
                postedByUserName: authorName
            }, {
                headers: { Authorization: `Bearer ${token}` }
            });

            // Reset form
            setNewJob({ title: '', company: '', description: '', location: '', employmentType: 'Full-Time', applyLink: '' });
            fetchJobs();
        } catch (err) {
            console.error("Failed to post job", err);
            setError("Failed to publish job posting.");
        }
    };

    const handleDeleteJob = async (jobId) => {
        if (!window.confirm("Are you sure you want to delete this job posting?")) return;

        const token = localStorage.getItem('token');
        try {
            await axios.delete(`http://localhost:8080/api/careers/${jobId}`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            fetchJobs();
        } catch (err) {
            console.error("Failed to delete job", err);
        }
    };

    return (
        <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
            <h2>Career Opportunities</h2>
            {error && <p style={{ color: 'red' }}>{error}</p>}

            {/* --- POST A JOB FORM --- */}
            <form onSubmit={handleCreateJob} style={{ marginBottom: '40px', padding: '20px', border: '1px solid #ccc', borderRadius: '8px', backgroundColor: '#f4f7f6' }}>
                <h3>Post a New Opportunity</h3>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginBottom: '10px' }}>
                    <input required placeholder="Job Title (e.g. Software Engineer)" value={newJob.title} onChange={e => setNewJob({...newJob, title: e.target.value})} style={{ padding: '8px' }} />
                    <input required placeholder="Company Name" value={newJob.company} onChange={e => setNewJob({...newJob, company: e.target.value})} style={{ padding: '8px' }} />
                    <input required placeholder="Location" value={newJob.location} onChange={e => setNewJob({...newJob, location: e.target.value})} style={{ padding: '8px' }} />
                    <select value={newJob.employmentType} onChange={e => setNewJob({...newJob, employmentType: e.target.value})} style={{ padding: '8px' }}>
                        <option value="Full-Time">Full-Time</option>
                        <option value="Internship">Internship</option>
                        <option value="Contract">Contract</option>
                    </select>
                </div>
                <textarea required rows="3" placeholder="Job Description & Requirements..." value={newJob.description} onChange={e => setNewJob({...newJob, description: e.target.value})} style={{ width: '100%', padding: '8px', marginBottom: '10px', boxSizing: 'border-box' }} />
                <input required placeholder="Application Link (URL)" value={newJob.applyLink} onChange={e => setNewJob({...newJob, applyLink: e.target.value})} style={{ width: '100%', padding: '8px', marginBottom: '10px', boxSizing: 'border-box' }} />

                <button type="submit" style={{ padding: '10px 20px', backgroundColor: '#28a745', color: 'white', border: 'none', borderRadius: '5px', cursor: 'pointer' }}>
                    Post Job
                </button>
            </form>

            {/* --- JOB LISTINGS --- */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                {jobs.length === 0 ? (
                    <p>No job postings available right now.</p>
                ) : (
                    jobs.map((job) => (
                        <div key={job.id} style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px', position: 'relative', boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
                            {String(job.postedByUserId) === String(currentUserId) && (
                                <button onClick={() => handleDeleteJob(job.id)} style={{ position: 'absolute', top: '20px', right: '20px', backgroundColor: '#dc3545', color: 'white', border: 'none', borderRadius: '4px', padding: '5px 10px', cursor: 'pointer' }}>
                                    Delete
                                </button>
                            )}
                            <h3 style={{ margin: '0 0 5px 0', color: '#0056b3' }}>{job.title}</h3>
                            <h4 style={{ margin: '0 0 15px 0', color: '#555' }}>{job.company} • {job.location} • <span style={{ backgroundColor: '#e9ecef', padding: '3px 8px', borderRadius: '12px', fontSize: '0.85em' }}>{job.employmentType}</span></h4>
                            <p style={{ whiteSpace: 'pre-wrap', lineHeight: '1.5' }}>{job.description}</p>
                            <div style={{ marginTop: '15px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <a href={job.applyLink} target="_blank" rel="noopener noreferrer" style={{ textDecoration: 'none', backgroundColor: '#007bff', color: 'white', padding: '8px 15px', borderRadius: '5px' }}>Apply Now</a>
                                <small style={{ color: '#888' }}>Posted by {job.postedByUserName}</small>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}