import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Home, MapPin, BedDouble, Trash2, Eye, Flag, Filter } from 'lucide-react';
import { mockListings } from '../data/mockData';
import Modal from '../components/Modal';
import { getListings, deleteListing } from '../api';

export default function Listings() {
    const navigate = useNavigate();
    const [listings, setListings] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [typeFilter, setTypeFilter] = useState('all');
    const [statusFilter, setStatusFilter] = useState('all');
    const [deleteModal, setDeleteModal] = useState(null);

    useEffect(() => {
        getListings()
            .then(({ data }) => setListings(data.data || []))
            .catch(() => setListings(mockListings))
            .finally(() => setLoading(false));
    }, []);

    const filtered = listings.filter(l => {
        const matchSearch = l.title.toLowerCase().includes(search.toLowerCase()) || l.location.toLowerCase().includes(search.toLowerCase());
        const matchType = typeFilter === 'all' || l.type === typeFilter;
        const matchStatus = statusFilter === 'all' || l.status === statusFilter;
        return matchSearch && matchType && matchStatus;
    });

    const handleDelete = async (id) => {
        try {
            await deleteListing(id);
            setListings(prev => prev.filter(l => (l._id || l.id) !== id));
        } catch { /* silently ignore */ }
        setDeleteModal(null);
    };

    return (
        <div>
            <div className="page-header">
                <h1>House Listings</h1>
                <p>View and manage all property listings</p>
            </div>

            <div className="filter-bar">
                <div className="input-with-icon" style={{ flex: 1, minWidth: 200 }}>
                    <Search size={16} className="input-icon" />
                    <input className="form-input" placeholder="Search by title or location..." value={search} onChange={e => setSearch(e.target.value)} />
                </div>
                <select className="form-select" style={{ width: 160 }} value={typeFilter} onChange={e => setTypeFilter(e.target.value)}>
                    <option value="all">All Types</option>
                    <option value="apartment">Apartment</option>
                    <option value="house">House</option>
                    <option value="studio">Studio</option>
                </select>
                <select className="form-select" style={{ width: 160 }} value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
                    <option value="all">All Listings</option>
                    <option value="active">Active</option>
                    <option value="pending">Pending</option>
                    <option value="suspended">Suspended</option>
                </select>
                <span style={{ fontSize: 13, color: 'var(--text-secondary)' }}>{filtered.length} listings</span>
            </div>

            {loading ? (
                <div style={{ padding: 40, textAlign: 'center', color: 'var(--text-secondary)' }}>Loading listings...</div>
            ) : filtered.length === 0 ? (
                <div className="card"><div className="empty-state"><Home size={40} /><h3>No listings found</h3></div></div>
            ) : (
                <div className="listings-grid">
                    {filtered.map(l => {
                        const lid = l._id || l.id;
                        const img = l.image || l.images?.[0];
                        return (
                        <div key={lid} className="listing-card">
                            <div className="listing-img">
                                {img
                                    ? <img src={img} alt={l.title} onError={e => { e.target.style.display = 'none'; e.target.nextSibling.style.display = 'flex'; }} />
                                    : null}
                                <div className="listing-img-placeholder" style={{ display: img ? 'none' : 'flex' }}><Home size={36} /></div>
                                {l.isPremium && <div className="listing-badge-overlay"><span className="badge badge-warning">⭐ Premium</span></div>}
                            </div>
                            <div className="listing-card-body">
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 6 }}>
                                    <h4 className="listing-title" style={{ marginBottom: 0 }}>{l.title}</h4>
                                    <span className={`badge badge-${l.status === 'active' ? 'success' : l.status === 'pending' ? 'warning' : 'error'}`}>{l.status}</span>
                                </div>
                                <div className="listing-meta">
                                    <div className="listing-meta-item"><MapPin size={13} />{l.location}</div>
                                    <div className="listing-meta-item"><BedDouble size={13} />{l.bedrooms} BR</div>
                                </div>
                                <p className="listing-desc">{l.description}</p>
                                <div style={{ fontSize: 12, color: 'var(--text-secondary)', marginBottom: 4 }}>
                                    Listed by: <span style={{ fontWeight: 600 }}>{l.owner?.name || l.owner}</span> · {l.views || 0} views · {l.inquiries || 0} inquiries
                                </div>
                            </div>
                            <div className="listing-card-footer">
                                <div className="listing-price">KES {(l.price || 0).toLocaleString()}<span>/mo</span></div>
                                <div style={{ display: 'flex', gap: 6 }}>
                                    <button className="btn-icon view" title="View Details" onClick={() => navigate(`/listings/${lid}`)}><Eye size={15} /></button>
                                    <button className="btn-icon delete" title="Delete Listing" onClick={() => setDeleteModal(l)}><Trash2 size={15} /></button>
                                </div>
                            </div>
                        </div>
                        );
                    })}
                </div>
            )}

            <Modal isOpen={!!deleteModal} onClose={() => setDeleteModal(null)} title="Delete Listing"
                footer={<><button className="btn btn-outline" onClick={() => setDeleteModal(null)}>Cancel</button><button className="btn btn-danger" onClick={() => handleDelete(deleteModal._id || deleteModal.id)}>Delete Listing</button></>}>
                <div className="alert alert-error">
                    Are you sure you want to permanently delete <strong>"{deleteModal?.title}"</strong>? The owner will be notified.
                </div>
            </Modal>
        </div>
    );
}
