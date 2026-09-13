import React from 'react';
import {
  FileText,
  Briefcase,
  Clock,
  Award,
  FileCheck,
  Newspaper,
  Eye,
  ArrowRight,
  TrendingUp,
  Bell,
  AlertCircle,
} from 'lucide-react';
import { ContentItem, NotificationLog } from '../types';
import { AdminCard } from '../components/common/AdminCard';
import { AdminBadge } from '../components/common/AdminBadge';
import { calculateJobStatus } from '../services/contentService';
import { NavView } from '../components/layout/AdminSidebar';

interface DashboardPageProps {
  items: ContentItem[];
  logs: NotificationLog[];
  onNavigate: (view: NavView) => void;
  onEditItem: (item: ContentItem) => void;
}

export const DashboardPage: React.FC<DashboardPageProps> = ({
  items,
  logs,
  onNavigate,
  onEditItem,
}) => {
  // Compute metric numbers
  const publishedItems = items.filter((i) => i.isPublished && i.status !== 'archived');
  const openJobs = publishedItems.filter(
    (i) =>
      i.contentType === 'government_job' &&
      calculateJobStatus(i.applicationLastDate, i.statusOverride).status === 'open'
  );
  const closingSoonJobs = publishedItems.filter((i) => {
    if (i.contentType !== 'government_job') return false;
    const st = calculateJobStatus(i.applicationLastDate, i.statusOverride).status;
    return st === 'closing_soon' || st === 'closing_today';
  });
  const resultsCount = publishedItems.filter((i) => i.contentType === 'result').length;
  const admitCardsCount = publishedItems.filter((i) => i.contentType === 'admit_card').length;
  const articlesCount = publishedItems.filter((i) => i.contentType === 'article').length;
  const totalViews = items.reduce((acc, curr) => acc + (curr.views || 0), 0);

  const stats = [
    {
      title: 'Published Content',
      value: publishedItems.length,
      icon: <FileText className="w-5 h-5 text-[#159B76]" />,
      bg: 'bg-emerald-50',
      change: 'Active on App',
    },
    {
      title: 'Open Jobs',
      value: openJobs.length,
      icon: <Briefcase className="w-5 h-5 text-blue-600" />,
      bg: 'bg-blue-50',
      change: 'Active Applications',
    },
    {
      title: 'Closing Soon',
      value: closingSoonJobs.length,
      icon: <Clock className="w-5 h-5 text-amber-600" />,
      bg: 'bg-amber-50',
      change: '< 3 Days Left',
    },
    {
      title: 'Results Published',
      value: resultsCount,
      icon: <Award className="w-5 h-5 text-orange-600" />,
      bg: 'bg-orange-50',
      change: 'Exam Outcomes',
    },
    {
      title: 'Admit Cards',
      value: admitCardsCount,
      icon: <FileCheck className="w-5 h-5 text-purple-600" />,
      bg: 'bg-purple-50',
      change: 'Hall Tickets Live',
    },
    {
      title: 'Articles & Guides',
      value: articlesCount,
      icon: <Newspaper className="w-5 h-5 text-slate-600" />,
      bg: 'bg-slate-100',
      change: 'Editorial Roadmaps',
    },
    {
      title: 'Total Post Views',
      value: totalViews.toLocaleString('en-IN'),
      icon: <Eye className="w-5 h-5 text-emerald-600" />,
      bg: 'bg-emerald-50',
      change: 'Real Aspirant Views',
    },
  ];

  // Most viewed
  const mostViewed = [...publishedItems].sort((a, b) => b.views - a.views).slice(0, 5);

  // Recent content
  const recentContent = [...items].slice(0, 5);

  return (
    <div className="space-y-8">
      {/* Metric Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat, idx) => (
          <div
            key={idx}
            className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm flex items-start justify-between"
          >
            <div>
              <p className="text-xs font-semibold text-slate-500">{stat.title}</p>
              <h3 className="text-2xl font-black text-slate-900 mt-1">
                {stat.value}
              </h3>
              <p className="text-[11px] font-medium text-slate-400 mt-1">
                {stat.change}
              </p>
            </div>
            <div className={`p-3 rounded-xl ${stat.bg}`}>{stat.icon}</div>
          </div>
        ))}
      </div>

      {/* Two Column Section Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Content */}
        <AdminCard
          title="Recent Content"
          subtitle="Recently updated jobs, admit cards, and articles"
          actions={
            <button
              onClick={() => onNavigate('content_all')}
              className="text-xs font-semibold text-[#159B76] hover:underline flex items-center gap-1"
            >
              View All <ArrowRight className="w-3.5 h-3.5" />
            </button>
          }
          noPadding
        >
          <div className="divide-y divide-slate-100">
            {recentContent.map((item) => {
              const status = calculateJobStatus(item.applicationLastDate, item.statusOverride);
              return (
                <div
                  key={item.id}
                  onClick={() => onEditItem(item)}
                  className="p-4 hover:bg-slate-50/80 cursor-pointer transition-colors flex items-center justify-between gap-3"
                >
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <AdminBadge variant="slate" size="sm">
                        {item.contentType}
                      </AdminBadge>
                      <AdminBadge
                        variant={item.isPublished ? 'success' : 'warning'}
                        size="sm"
                      >
                        {item.status}
                      </AdminBadge>
                    </div>
                    <p className="text-sm font-semibold text-slate-900 truncate">
                      {item.title}
                    </p>
                    <p className="text-xs text-slate-500 truncate mt-0.5">
                      {item.organization} • {item.vacancies ? `${item.vacancies} Posts` : 'N/A'}
                    </p>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <span className="text-xs font-medium text-slate-400 block">
                      {item.views.toLocaleString()} views
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        </AdminCard>

        {/* Jobs Closing Soon */}
        <AdminCard
          title="Jobs Closing Soon"
          subtitle="Urgent deadlines within the next 3 days"
          actions={
            <AdminBadge variant="warning" size="sm">
              {closingSoonJobs.length} Urgent
            </AdminBadge>
          }
          noPadding
        >
          <div className="divide-y divide-slate-100">
            {closingSoonJobs.length === 0 ? (
              <div className="p-8 text-center text-xs text-slate-400">
                No jobs closing in the next 3 days. All active deadlines are comfortable!
              </div>
            ) : (
              closingSoonJobs.map((item) => {
                const status = calculateJobStatus(item.applicationLastDate, item.statusOverride);
                return (
                  <div
                    key={item.id}
                    onClick={() => onEditItem(item)}
                    className="p-4 hover:bg-slate-50/80 cursor-pointer transition-colors flex items-center justify-between gap-3"
                  >
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <AdminBadge variant="warning" size="sm">
                          {status.label}
                        </AdminBadge>
                        <span className="text-[11px] text-red-600 font-semibold">
                          Deadline: {item.applicationLastDate}
                        </span>
                      </div>
                      <p className="text-sm font-semibold text-slate-900 truncate">
                        {item.title}
                      </p>
                      <p className="text-xs text-slate-500 truncate mt-0.5">
                        {item.organization}
                      </p>
                    </div>
                    <ArrowRight className="w-4 h-4 text-slate-400 flex-shrink-0" />
                  </div>
                );
              })
            )}
          </div>
        </AdminCard>
      </div>

      {/* Second Row: Most Viewed & Recent Notifications */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Most Viewed This Week */}
        <AdminCard
          title="Most Viewed Content"
          subtitle="Opportunities attracting the highest applicant traffic"
          noPadding
        >
          <div className="divide-y divide-slate-100">
            {mostViewed.map((item, idx) => (
              <div
                key={item.id}
                onClick={() => onEditItem(item)}
                className="p-4 hover:bg-slate-50/80 cursor-pointer transition-colors flex items-center gap-3.5"
              >
                <div className="w-7 h-7 rounded-xl bg-slate-100 text-slate-600 font-bold text-xs flex items-center justify-center flex-shrink-0">
                  #{idx + 1}
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-semibold text-slate-900 truncate">
                    {item.title}
                  </p>
                  <p className="text-xs text-slate-500 truncate">
                    {item.organization} • {item.vacancies || '0'} Vacancies
                  </p>
                </div>
                <div className="flex items-center gap-1.5 text-xs font-bold text-[#159B76]">
                  <TrendingUp className="w-3.5 h-3.5" />
                  <span>{item.views.toLocaleString()}</span>
                </div>
              </div>
            ))}
          </div>
        </AdminCard>

        {/* Recent Notifications */}
        <AdminCard
          title="Recent Push Notifications"
          subtitle="FCM alerts sent to subscribers"
          actions={
            <button
              onClick={() => onNavigate('notifications')}
              className="text-xs font-semibold text-[#159B76] hover:underline flex items-center gap-1"
            >
              Send New <ArrowRight className="w-3.5 h-3.5" />
            </button>
          }
          noPadding
        >
          <div className="divide-y divide-slate-100">
            {logs.slice(0, 4).map((log) => (
              <div key={log.id} className="p-4 flex items-start gap-3">
                <div className="p-2 rounded-xl bg-[#ECFDF5] text-[#117A5E] flex-shrink-0 mt-0.5">
                  <Bell className="w-4 h-4" />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between gap-2">
                    <p className="text-xs font-bold text-slate-900 truncate">
                      {log.title}
                    </p>
                    <span className="text-[10px] text-slate-400 whitespace-nowrap">
                      {new Date(log.sentAt).toLocaleDateString()}
                    </span>
                  </div>
                  <p className="text-xs text-slate-600 line-clamp-1 mt-0.5">
                    {log.body}
                  </p>
                  <div className="flex items-center gap-2 mt-1.5">
                    <AdminBadge variant="slate" size="sm">
                      Topic: {log.topic}
                    </AdminBadge>
                    <AdminBadge variant="success" size="sm">
                      {log.status}
                    </AdminBadge>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </AdminCard>
      </div>
    </div>
  );
};
