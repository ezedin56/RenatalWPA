import { useState } from 'react';
import { Home, Eye, EyeOff, AlertCircle } from 'lucide-react';
import { loginAdmin } from '../api';

export default function Login({ onLogin }) {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPw, setShowPw] = useState(false);
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setLoading(true);
        try {
            const { data } = await loginAdmin(email, password);
            if (data.data.user.role !== 'admin') {
                setError('Access denied. Admin accounts only.');
                return;
            }
            localStorage.setItem('admin_token', data.data.token);
            onLogin(data.data.user);
        } catch (err) {
            const msg = err.response?.data?.error?.message || 'Invalid email or password.';
            setError(msg);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="login-page">
            <div className="login-card">
                <div className="login-brand">
                    <div className="login-icon">
                        <Home size={28} color="white" />
                    </div>
                    <h1>Admin Dashboard</h1>
                    <p>House Rental Platform</p>
                </div>

                {error && (
                    <div className="login-error">
                        <AlertCircle size={14} style={{ display: 'inline', marginRight: 6 }} />
                        {error}
                    </div>
                )}

                <form onSubmit={handleSubmit} className="login-form">
                    <div className="form-group">
                        <label className="form-label">Email Address</label>
                        <input
                            className="form-input"
                            type="email"
                            placeholder="admin@houserental.com"
                            value={email}
                            onChange={e => setEmail(e.target.value)}
                            required
                            autoFocus
                        />
                    </div>
                    <div className="form-group">
                        <label className="form-label">Password</label>
                        <div className="input-with-icon">
                            <input
                                className="form-input"
                                type={showPw ? 'text' : 'password'}
                                placeholder="Enter your password"
                                value={password}
                                onChange={e => setPassword(e.target.value)}
                                required
                            />
                            <button
                                type="button"
                                className="input-icon input-icon-right"
                                onClick={() => setShowPw(p => !p)}
                                style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}
                            >
                                {showPw ? <EyeOff size={16} /> : <Eye size={16} />}
                            </button>
                        </div>
                    </div>
                    <button className="btn btn-primary" type="submit" disabled={loading} style={{ width: '100%', justifyContent: 'center' }}>
                        {loading ? 'Signing in...' : 'Sign In'}
                    </button>
                </form>
            </div>
        </div>
    );
}
