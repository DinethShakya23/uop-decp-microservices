import { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

export default function CareersPage() {
    const [jobs, setJobs] = useState([]);
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const currentUserId = localStorage.getItem('userId');
    const currentUserName = localStorage.getItem('userName');
    const role = localStorage.getItem('role');

    const [newJob, setNewJob] = useState({
        title: '', company: '', description: '', type: 'JOB'
    });

    const [selectedJob, setSelectedJob] = useState(null);
    const [applicationData, setApplicationData] = useState({ coverLetter: '', resumeUrl: '' });
    const [applyStatus, setApplyStatus] = useState('');

    const [jobApplicants, setJobApplicants] = useState({});
    const [expandedJobId, setExpandedJobId] = useState(null);

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
            const response = await axios.get('/api/jobs', {
                headers: { Authorization: `Bearer ${token}` }
            });
            setJobs(response.data);
        } catch (err) {
            setError('Failed to load careers.');
        }
    };

    const handleCreateJob = async (e) => {
        e.preventDefault();
        const token = localStorage.getItem('token');
        try {
            await axios.post('/api/jobs', newJob, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setNewJob({ title: '', company: '', description: '', type: 'JOB' });
            fetchJobs();
        } catch (err) {
            setError("Failed to publish job posting.");
        }
    };

    const handleDeleteJob = async (jobId) => {
        if (!window.confirm("Delete this job posting?")) return;
        const token = localStorage.getItem('token');
        try {
            await axios.delete(`/api/jobs/${jobId}`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            fetchJobs();
        } catch (err) {
            console.error("Failed to delete job", err);
        }
    };

    const handleSubmitApplication = async (e) => {
        e.preventDefault();
        setApplyStatus('Submitting...');
        const token = localStorage.getItem('token');
        try {
            await axios.post(`/api/jobs/${selectedJob.id}/apply`, {
                coverLetter: applicationData.coverLetter,
                resumeUrl: applicationData.resumeUrl
            }, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setApplyStatus('success');
            setTimeout(() => {
                setSelectedJob(null);
                setApplyStatus('');
                setApplicationData({ coverLetter: '', resumeUrl: '' });
            }, 2000);
        } catch (err) {
            setApplyStatus('error');
        }
    };

    const handleToggleApplicants = async (jobId) => {
        if (expandedJobId === jobId) {
            setExpandedJobId(null);
            return;
        }
        const token = localStorage.getItem('token');
        try {
            const response = await axios.get(`/api/jobs/applications/job/${jobId}`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setJobApplicants({ ...jobApplicants, [jobId]: response.data });
            setExpandedJobId(jobId);
        } catch (err) {
            console.error("Failed to fetch applicants", err);
        }
    };

    return (
        <div className="main-layout">
            {/* Sidebar */}
            <aside className="sidebar-left">
                <div className="li-card" style={{ padding: '12px' }}>
                    <div style={{ fontWeight: '600', fontSize: '16px', marginBottom: '16px' }}>Jobs for you</div>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                        <div style={{ fontSize: '14px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', cursor: 'pointer' }}>My Jobs</div>
                        <div style={{ fontSize: '14px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', cursor: 'pointer' }}>Job Alerts</div>
                        <div style={{ fontSize: '14px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', cursor: 'pointer' }}>Skill Assessments</div>
                        <div style={{ fontSize: '14px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', cursor: 'pointer' }}>Interview Prep</div>
                    </div>
                </div>
            </aside>

            {/* Main Area */}
            <main>
                {(role === 'ALUMNI' || role === 'ADMIN') && (
                    <div className="li-card" style={{ padding: '16px' }}>
                        <div style={{ fontSize: '18px', fontWeight: '600', marginBottom: '16px' }}>Post a New Job</div>
                        <form onSubmit={handleCreateJob} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                            <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
                                <input required placeholder="Job Title" className="li-input" style={{ flex: '1 1 200px' }} value={newJob.title} onChange={e => setNewJob({...newJob, title: e.target.value})} />
                                <input required placeholder="Company" className="li-input" style={{ flex: '1 1 200px' }} value={newJob.company} onChange={e => setNewJob({...newJob, company: e.target.value})} />
                            </div>
                            <select value={newJob.type} className="li-input" onChange={e => setNewJob({...newJob, type: e.target.value})}>
                                <option value="JOB">Full-Time Job</option>
                                <option value="INTERNSHIP">Internship</option>
                            </select>
                            <textarea required rows="4" className="li-input" placeholder="Job Description and requirements..." value={newJob.description} onChange={e => setNewJob({...newJob, description: e.target.value})} />
                            <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
                                <button type="submit" className="li-btn li-btn-primary">Post Job</button>
                            </div>
                        </form>
                    </div>
                )}

                <div className="li-card" style={{ padding: '12px 16px' }}>
                    <div style={{ fontSize: '18px', fontWeight: '600', marginBottom: '12px' }}>Recommended for you</div>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '0' }}>
                        {jobs.length === 0 ? (
                            <p style={{ color: 'var(--linkedin-text-secondary)', padding: '20px 0' }}>No jobs found.</p>
                        ) : (
                            jobs.map((job) => {
                                const isOwner = String(job.postedBy) === String(currentUserId);
                                return (
                                    <div key={job.id} style={{ padding: '16px 0', borderBottom: '1px solid var(--linkedin-border)', position: 'relative' }}>
                                        <div style={{ display: 'flex', gap: '12px' }}>
                                            <div style={{ width: '56px', height: '56px', background: '#f3f2ef', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px', fontWeight: 'bold', color: 'var(--linkedin-blue)', borderRadius: '4px' }}>
                                                {job.company.charAt(0).toUpperCase()}
                                            </div>
                                            <div style={{ flex: 1 }}>
                                                <div style={{ fontSize: '16px', fontWeight: '600', color: 'var(--linkedin-blue)', cursor: 'pointer' }}>{job.title}</div>
                                                <div style={{ fontSize: '14px', marginTop: '2px' }}>{job.company}</div>
                                                <div style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', marginTop: '2px' }}>UniConnect Networking • Remote</div>
                                                <div style={{ fontSize: '12px', color: 'var(--success-color)', fontWeight: '600', marginTop: '4px' }}>
                                                    {job.type} • Actively recruiting
                                                </div>
                                                <div style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', marginTop: '8px' }}>
                                                    {new Date(job.createdAt).toLocaleDateString()}
                                                </div>
                                                
                                                <div style={{ marginTop: '12px', display: 'flex', gap: '8px' }}>
                                                    <button onClick={() => setSelectedJob(job)} className="li-btn li-btn-outline" style={{ fontSize: '14px', padding: '4px 12px' }}>Easy Apply</button>
                                                    {isOwner && (
                                                        <>
                                                            <button onClick={() => handleToggleApplicants(job.id)} className="li-btn li-btn-ghost" style={{ fontSize: '14px', padding: '4px 12px' }}>
                                                                {expandedJobId === job.id ? 'Hide Applicants' : 'View Applicants'}
                                                            </button>
                                                            <button onClick={() => handleDeleteJob(job.id)} className="li-btn li-btn-ghost" style={{ fontSize: '14px', padding: '4px 12px', color: '#dc3545' }}>Delete</button>
                                                        </>
                                                    )}
                                                </div>

                                                {expandedJobId === job.id && (
                                                    <div style={{ marginTop: '16px', padding: '12px', background: 'var(--linkedin-bg)', borderRadius: '8px' }}>
                                                        <div style={{ fontSize: '14px', fontWeight: '600', marginBottom: '8px' }}>Applications</div>
                                                        {(!jobApplicants[job.id] || jobApplicants[job.id].length === 0) ? (
                                                            <p style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)' }}>No applications yet.</p>
                                                        ) : (
                                                            jobApplicants[job.id].map(app => (
                                                                <div key={app.id} style={{ marginBottom: '8px', padding: '8px', background: '#fff', borderRadius: '4px' }}>
                                                                    <div style={{ fontSize: '13px', fontWeight: '600' }}>Applicant ID: {app.applicantId}</div>
                                                                    <div style={{ fontSize: '12px', marginTop: '4px' }}>{app.coverLetter}</div>
                                                                    <a href={app.resumeUrl} target="_blank" rel="noopener noreferrer" style={{ fontSize: '12px', color: 'var(--linkedin-blue)', textDecoration: 'none', fontWeight: '600', display: 'block', marginTop: '4px' }}>View Resume</a>
                                                                </div>
                                                            ))
                                                        )}
                                                    </div>
                                                )}
                                            </div>
                                        </div>
                                    </div>
                                );
                            })
                        )}
                    </div>
                </div>
            </main>

            {/* Application Modal */}
            {selectedJob && (
                <div style={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
                    <div className="li-card" style={{ width: '500px', padding: '24px', position: 'relative' }}>
                        <button onClick={() => setSelectedJob(null)} style={{ position: 'absolute', right: '16px', top: '16px', background: 'none', border: 'none', fontSize: '20px', cursor: 'pointer' }}>&times;</button>
                        <h2 style={{ fontSize: '20px', fontWeight: '600', marginBottom: '4px' }}>Apply to {selectedJob.company}</h2>
                        <p style={{ fontSize: '14px', color: 'var(--linkedin-text-secondary)', marginBottom: '24px' }}>{selectedJob.title}</p>
                        
                        <form onSubmit={handleSubmitApplication} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                            <div>
                                <label style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', display: 'block', marginBottom: '4px' }}>Cover Letter</label>
                                <textarea required rows="5" className="li-input" value={applicationData.coverLetter} onChange={e => setApplicationData({...applicationData, coverLetter: e.target.value})} />
                            </div>
                            <div>
                                <label style={{ fontSize: '12px', color: 'var(--linkedin-text-secondary)', fontWeight: '600', display: 'block', marginBottom: '4px' }}>Resume URL</label>
                                <input required className="li-input" value={applicationData.resumeUrl} onChange={e => setApplicationData({...applicationData, resumeUrl: e.target.value})} />
                            </div>
                            <button type="submit" className="li-btn li-btn-primary" style={{ alignSelf: 'flex-end' }}>Submit Application</button>
                        </form>
                        {applyStatus === 'success' && <p style={{ marginTop: '16px', color: 'var(--success-color)', textAlign: 'center' }}>Application sent!</p>}
                    </div>
                </div>
            )}
        </div>
    );
}