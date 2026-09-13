import React, { useState } from 'react';
import {
  Bookmark,
  Share2,
  Calendar,
  GraduationCap,
  Users,
  Building,
  ExternalLink,
  Lock,
  ArrowLeft,
  X,
  Clock,
  Briefcase,
} from 'lucide-react';
import { ContentItem } from '../../types';
import { calculateJobStatus } from '../../services/contentService';

interface MobilePreviewModalProps {
  isOpen: boolean;
  onClose: () => void;
  item: Partial<ContentItem>;
}

export const MobilePreviewModal: React.FC<MobilePreviewModalProps> = ({
  isOpen,
  onClose,
  item,
}) => {
  const [tab, setTab] = useState<'card' | 'detail'>('detail');

  if (!isOpen) return null;

  const statusInfo = calculateJobStatus(
    item.applicationLastDate,
    item.statusOverride
  );

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/70 backdrop-blur-sm overflow-y-auto">
      <div className="bg-slate-900 rounded-[40px] p-4 shadow-2xl border-4 border-slate-700 max-w-[390px] w-full my-8 relative">
        {/* Device Notch & Top Bar */}
        <div className="flex items-center justify-between px-6 py-2 text-white/60 text-xs mb-2">
          <span>9:41</span>
          <div className="w-24 h-4 bg-black rounded-full" />
          <button
            onClick={onClose}
            className="p-1 rounded-full bg-white/10 hover:bg-white/20 text-white"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>

        {/* Screen Switcher */}
        <div className="flex bg-slate-800 p-1 rounded-xl mb-3">
          <button
            type="button"
            onClick={() => setTab('card')}
            className={`flex-1 py-1 text-xs font-semibold rounded-lg transition-colors ${
              tab === 'card'
                ? 'bg-[#159B76] text-white shadow-sm'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            Job Card
          </button>
          <button
            type="button"
            onClick={() => setTab('detail')}
            className={`flex-1 py-1 text-xs font-semibold rounded-lg transition-colors ${
              tab === 'detail'
                ? 'bg-[#159B76] text-white shadow-sm'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            Job Detail
          </button>
        </div>

        {/* Mobile Viewport Screen */}
        <div className="bg-[#F8FAFC] rounded-[28px] overflow-hidden min-h-[580px] max-h-[640px] flex flex-col text-slate-900 shadow-inner">
          {tab === 'card' ? (
            <div className="p-4 flex-1 overflow-y-auto space-y-4">
              <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400 px-1">
                Feed Preview
              </div>

              {/* Mobile Job Card */}
              <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-sm space-y-3">
                <div className="flex items-center justify-between gap-2">
                  <span className="px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-[#ECFDF5] text-[#117A5E] border border-[#159B76]/20">
                    {item.contentType === 'government_job' ? 'Govt Job' : item.contentType}
                  </span>
                  <span
                    className="px-2.5 py-0.5 rounded-full text-[11px] font-semibold"
                    style={{
                      backgroundColor: `${statusInfo.color}15`,
                      color: statusInfo.color,
                      borderColor: `${statusInfo.color}30`,
                      borderWidth: 1,
                    }}
                  >
                    {statusInfo.label}
                  </span>
                </div>

                <div>
                  <h4 className="text-sm font-bold text-slate-900 leading-snug line-clamp-2">
                    {item.title || 'Untitled Notification'}
                  </h4>
                  <p className="text-xs text-slate-500 mt-1 flex items-center gap-1 font-medium">
                    <Building className="w-3 h-3 text-slate-400 flex-shrink-0" />
                    <span className="truncate">{item.organization || 'Department'}</span>
                  </p>
                </div>

                {/* Compact Metadata Strip */}
                <div className="grid grid-cols-3 gap-2 py-2 border-y border-slate-100 text-[11px]">
                  <div>
                    <span className="text-slate-400 block text-[10px]">Vacancies</span>
                    <span className="font-semibold text-slate-800">
                      {item.vacancies || 'N/A'}
                    </span>
                  </div>
                  <div>
                    <span className="text-slate-400 block text-[10px]">Qualification</span>
                    <span className="font-semibold text-slate-800 truncate block">
                      {item.qualification || 'N/A'}
                    </span>
                  </div>
                  <div>
                    <span className="text-slate-400 block text-[10px]">Last Date</span>
                    <span className="font-semibold text-slate-800">
                      {item.applicationLastDate || 'TBA'}
                    </span>
                  </div>
                </div>

                {/* Bottom Actions */}
                <div className="flex items-center justify-between pt-1">
                  <div className="flex items-center gap-2">
                    <button className="p-2 rounded-xl text-slate-400 hover:text-[#159B76] hover:bg-slate-50">
                      <Bookmark className="w-4 h-4" />
                    </button>
                    <button className="p-2 rounded-xl text-slate-400 hover:text-[#159B76] hover:bg-slate-50">
                      <Share2 className="w-4 h-4" />
                    </button>
                  </div>
                  <button
                    onClick={() => setTab('detail')}
                    className="px-3.5 py-1.5 rounded-xl bg-[#159B76] text-white text-xs font-semibold shadow-sm"
                  >
                    View Details
                  </button>
                </div>
              </div>
            </div>
          ) : (
            <div className="flex-1 overflow-y-auto flex flex-col">
              {/* Detail Screen Header */}
              <div className="sticky top-0 bg-white/95 backdrop-blur px-4 py-3 border-b border-slate-100 flex items-center justify-between">
                <button
                  onClick={() => setTab('card')}
                  className="p-1.5 rounded-xl hover:bg-slate-100 text-slate-600"
                >
                  <ArrowLeft className="w-4 h-4" />
                </button>
                <span className="text-xs font-bold text-slate-800 truncate max-w-[200px]">
                  {item.organization || 'Job Details'}
                </span>
                <div className="flex items-center gap-1">
                  <button className="p-1.5 rounded-xl text-slate-500 hover:bg-slate-100">
                    <Bookmark className="w-4 h-4" />
                  </button>
                  <button className="p-1.5 rounded-xl text-slate-500 hover:bg-slate-100">
                    <Share2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Detail Content Body */}
              <div className="p-4 space-y-4 flex-1">
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <span className="px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-[#ECFDF5] text-[#117A5E]">
                      {item.contentType || 'Govt Job'}
                    </span>
                    <span
                      className="px-2.5 py-0.5 rounded-full text-[10px] font-semibold"
                      style={{
                        backgroundColor: `${statusInfo.color}15`,
                        color: statusInfo.color,
                      }}
                    >
                      {statusInfo.label}
                    </span>
                  </div>
                  <h3 className="text-sm font-bold text-slate-900 leading-snug">
                    {item.title || 'Untitled Notification'}
                  </h3>
                  <p className="text-xs text-slate-500 font-medium">
                    {item.organization}
                    {item.department ? ` • ${item.department}` : ''}
                  </p>
                </div>

                {/* Quick Overview 2-Column Grid */}
                <div className="grid grid-cols-2 gap-2">
                  <div className="p-2.5 rounded-xl bg-white border border-slate-200">
                    <span className="text-[10px] text-slate-400 flex items-center gap-1">
                      <Users className="w-3 h-3 text-[#159B76]" /> Vacancies
                    </span>
                    <p className="text-xs font-bold text-slate-800 mt-1">
                      {item.vacancies || 'N/A'}
                    </p>
                  </div>
                  <div className="p-2.5 rounded-xl bg-white border border-slate-200">
                    <span className="text-[10px] text-slate-400 flex items-center gap-1">
                      <GraduationCap className="w-3 h-3 text-blue-500" /> Qualification
                    </span>
                    <p className="text-xs font-bold text-slate-800 mt-1 truncate">
                      {item.qualification || 'N/A'}
                    </p>
                  </div>
                  <div className="p-2.5 rounded-xl bg-white border border-slate-200">
                    <span className="text-[10px] text-slate-400 flex items-center gap-1">
                      <Clock className="w-3 h-3 text-amber-500" /> Last Date
                    </span>
                    <p className="text-xs font-bold text-slate-800 mt-1">
                      {item.applicationLastDate || 'TBA'}
                    </p>
                  </div>
                  <div className="p-2.5 rounded-xl bg-white border border-slate-200">
                    <span className="text-[10px] text-slate-400 flex items-center gap-1">
                      <Briefcase className="w-3 h-3 text-emerald-500" /> Salary
                    </span>
                    <p className="text-xs font-bold text-slate-800 mt-1 truncate">
                      {item.salary || 'As per norms'}
                    </p>
                  </div>
                </div>

                {/* Important Dates */}
                {item.importantDates && item.importantDates.length > 0 && (
                  <div className="bg-white rounded-2xl p-3.5 border border-slate-200 space-y-2">
                    <h5 className="text-xs font-bold text-slate-800 flex items-center gap-1.5">
                      <Calendar className="w-3.5 h-3.5 text-[#159B76]" /> Important Dates
                    </h5>
                    <div className="space-y-1.5 text-xs">
                      {item.importantDates.map((d, i) => (
                        <div key={i} className="flex justify-between py-1 border-b border-slate-50 last:border-none">
                          <span className="text-slate-500 text-[11px]">{d.label}</span>
                          <span className="font-semibold text-slate-800 text-[11px]">{d.date}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Important Links */}
                <div className="space-y-2 pt-1">
                  {item.applyUrl && (
                    <div className="p-3 rounded-xl bg-[#159B76] text-white flex items-center justify-between shadow-sm">
                      <span className="text-xs font-semibold">Apply Online (Direct Link)</span>
                      <ExternalLink className="w-3.5 h-3.5" />
                    </div>
                  )}

                  {item.officialNotificationUrl && (
                    <div className="p-3 rounded-xl bg-amber-500/10 border border-amber-300/40 text-amber-900 flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <Lock className="w-3.5 h-3.5 text-amber-600" />
                        <span className="text-xs font-semibold">Official Notification PDF</span>
                      </div>
                      <span className="text-[10px] bg-amber-200/80 px-2 py-0.5 rounded-full font-bold text-amber-800">
                        Rewarded Ad
                      </span>
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
