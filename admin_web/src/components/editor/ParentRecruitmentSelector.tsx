import React, { useState, useEffect } from 'react';
import { Search, Link as LinkIcon, X, Check, Briefcase } from 'lucide-react';
import { collection, query, where, getDocs, limit } from 'firebase/firestore';
import { db } from '../../firebase/config';

interface ParentRecruitmentSelectorProps {
  selectedId?: string;
  selectedTitle?: string;
  onSelect: (id: string, title: string) => void;
  onClear: () => void;
}

interface RecruitmentOption {
  id: string;
  title: string;
  organization: string;
  contentType: string;
}

export const ParentRecruitmentSelector: React.FC<ParentRecruitmentSelectorProps> = ({
  selectedId,
  selectedTitle,
  onSelect,
  onClear,
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [options, setOptions] = useState<RecruitmentOption[]>([]);

  useEffect(() => {
    const fetchRecentJobs = async () => {
      setLoading(true);
      try {
        const q = query(
          collection(db, 'content'),
          where('contentType', 'in', ['government_job', 'andaman_job', 'private_job']),
          limit(30)
        );
        const snap = await getDocs(q);
        const items: RecruitmentOption[] = [];
        snap.forEach((doc) => {
          const data = doc.data();
          items.push({
            id: doc.id,
            title: data.title || 'Untitled Post',
            organization: data.organization || '',
            contentType: data.contentType || 'job',
          });
        });
        setOptions(items);
      } catch (err) {
        console.error('Error fetching parent recruitments:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchRecentJobs();
  }, []);

  const filtered = options.filter(
    (opt) =>
      opt.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      opt.organization.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-2">
      <label className="block text-xs font-semibold text-slate-700">
        Parent Recruitment (Optional Link)
      </label>
      <p className="text-[11px] text-slate-500">
        Link this update, admit card, result, or answer key to its original parent recruitment post.
      </p>

      {selectedId ? (
        <div className="flex items-center justify-between p-3 rounded-xl bg-emerald-50 border border-emerald-200">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-8 h-8 rounded-lg bg-[#159B76]/10 text-[#159B76] flex items-center justify-center shrink-0">
              <Briefcase className="w-4 h-4" />
            </div>
            <div className="min-w-0">
              <div className="text-xs font-bold text-slate-900 truncate">
                {selectedTitle || selectedId}
              </div>
              <div className="text-[10px] text-slate-500 font-mono">ID: {selectedId}</div>
            </div>
          </div>
          <button
            type="button"
            onClick={onClear}
            className="p-1.5 rounded-lg text-slate-400 hover:text-rose-600 hover:bg-rose-50 transition-colors"
            title="Remove Link"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      ) : (
        <div className="relative">
          <div className="relative">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input
              type="text"
              value={searchTerm}
              onFocus={() => setIsOpen(true)}
              onChange={(e) => {
                setSearchTerm(e.target.value);
                setIsOpen(true);
              }}
              placeholder="Search by recruitment title or organization..."
              className="w-full pl-9 pr-3 py-2 text-xs rounded-xl border border-slate-200 bg-white focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76]"
            />
          </div>

          {isOpen && (
            <div className="absolute z-20 top-full left-0 right-0 mt-1 max-h-56 overflow-y-auto bg-white rounded-xl border border-slate-200 shadow-lg py-1">
              {loading ? (
                <div className="p-3 text-center text-xs text-slate-400">Loading recruitments...</div>
              ) : filtered.length === 0 ? (
                <div className="p-3 text-center text-xs text-slate-400">
                  No matching recruitments found.
                </div>
              ) : (
                filtered.map((item) => (
                  <button
                    key={item.id}
                    type="button"
                    onClick={() => {
                      onSelect(item.id, item.title);
                      setIsOpen(false);
                      setSearchTerm('');
                    }}
                    className="w-full text-left px-3.5 py-2 hover:bg-slate-50 flex items-center justify-between gap-2 border-b border-slate-50 last:border-0"
                  >
                    <div className="min-w-0">
                      <div className="text-xs font-semibold text-slate-900 truncate">
                        {item.title}
                      </div>
                      <div className="text-[10px] text-slate-500">
                        {item.organization} • {item.contentType.replace('_', ' ')}
                      </div>
                    </div>
                    <LinkIcon className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                  </button>
                ))
              )}
              <div className="p-2 border-t border-slate-100 flex justify-end">
                <button
                  type="button"
                  onClick={() => setIsOpen(false)}
                  className="text-[11px] font-semibold text-slate-500 hover:text-slate-800"
                >
                  Close
                </button>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
