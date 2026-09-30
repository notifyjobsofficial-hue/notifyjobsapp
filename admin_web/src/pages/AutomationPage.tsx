import React, { useState, useEffect } from 'react';
import {
  Cpu,
  Sparkles,
  Layers,
  Clock,
  CheckCircle,
  AlertTriangle,
  XCircle,
  ShieldAlert,
  Play,
  RefreshCw,
  Plus,
  Trash2,
  Edit,
  ExternalLink,
  ChevronRight,
  Eye,
  FileText,
  Search,
  Filter,
  Check,
  X,
  Sliders,
  Settings,
  List,
  Copy,
  ArrowRight,
  Database,
  Calendar,
  Lock,
  Zap,
} from 'lucide-react';
import {
  SourceConfig,
  DiscoveredItem,
  AutomationLog,
  GeminiSettings,
  QueueItemStatus,
  SourceStatus,
  SourceType,
  CheckFrequency,
} from '../types/automation';
import { ContentItem, ContentType, Category } from '../types';
import {
  fetchSources,
  saveSource,
  deleteSource,
  fetchQueueItems,
  fetchAutomationLogs,
  fetchGeminiSettings,
  saveGeminiSettings,
  runSourcePipeline,
  approveAndPublishItem,
  rejectItem,
  markDuplicateItem,
  saveQueueItem,
  deleteQueueItem,
  calculateConfidenceScores,
  validateExtractedItem,
  defaultGeminiSettings,
} from '../services/automationService';

export type AutomationTab =
  | 'sources'
  | 'collection_queue'
  | 'ai_queue'
  | 'review_queue'
  | 'duplicate_review'
  | 'history'
  | 'scheduler_settings'
  | 'activity_logs';

interface AutomationPageProps {
  userEmail: string;
  categories: Category[];
  onEditInSmartEditor: (item: Partial<ContentItem>) => void;
  onShowToast: (type: 'success' | 'error' | 'info', title: string, message?: string) => void;
}

export const AutomationPage: React.FC<AutomationPageProps> = ({
  userEmail,
  categories,
  onEditInSmartEditor,
  onShowToast,
}) => {
  const [activeTab, setActiveTab] = useState<AutomationTab>('sources');
  const [loading, setLoading] = useState(true);

  // Data states
  const [sources, setSources] = useState<SourceConfig[]>([]);
  const [queueItems, setQueueItems] = useState<DiscoveredItem[]>([]);
  const [logs, setLogs] = useState<AutomationLog[]>([]);
  const [geminiSettings, setGeminiSettings] = useState<GeminiSettings>(defaultGeminiSettings);

  // Modal / Form states
  const [showSourceModal, setShowSourceModal] = useState(false);
  const [editingSource, setEditingSource] = useState<Partial<SourceConfig> | null>(null);
  const [selectedReviewItem, setSelectedReviewItem] = useState<DiscoveredItem | null>(null);
  const [runningSourceId, setRunningSourceId] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [logFilter, setLogFilter] = useState<string>('all');
  const [testingApiKey, setTestingApiKey] = useState(false);

  // Load all initial automation data
  const loadData = async () => {
    setLoading(true);
    try {
      const [srcList, items, logList, gSettings] = await Promise.all([
        fetchSources(),
        fetchQueueItems('ALL'),
        fetchAutomationLogs(150),
        fetchGeminiSettings(),
      ]);
      setSources(srcList);
      setQueueItems(items);
      setLogs(logList);
      setGeminiSettings(gSettings);
    } catch (err) {
      console.error('Error loading automation data:', err);
      onShowToast('error', 'Failed to load automation data');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  // Filter queues
  const collectionQueue = queueItems.filter((i) => i.status === 'NEW' || i.status === 'FETCHED');
  const aiQueue = queueItems.filter((i) => i.status === 'PROCESSING');
  const reviewQueue = queueItems.filter((i) => i.status === 'REVIEW');
  const duplicateQueue = queueItems.filter((i) => i.status === 'DUPLICATE');
  const historyQueue = queueItems.filter(
    (i) => i.status === 'PUBLISHED' || i.status === 'FAILED' || i.status === 'BLOCKED'
  );

  // Handler: Run pipeline for a source
  const handleRunSource = async (source: SourceConfig) => {
    setRunningSourceId(source.id);
    onShowToast('info', `Running pipeline for ${source.name}...`, 'Discovering and extracting notices');
    try {
      const report = await runSourcePipeline(source, userEmail);
      if (report.status === 'blocked') {
        onShowToast('error', `Portal Blocked Automated Access`, report.error || 'Marked as BLOCKED / MANUAL REQUIRED');
      } else if (report.status === 'failed') {
        onShowToast('error', `Pipeline Failed`, report.error);
      } else {
        onShowToast(
          'success',
          `Pipeline Completed for ${source.name}`,
          `Discovered: ${report.linksDiscovered}, Auto-published: ${report.itemsAutoPublished}, In Review: ${report.itemsSentToReview}`
        );
      }
      await loadData();
    } catch (err: any) {
      console.error('Pipeline error:', err);
      onShowToast('error', 'Pipeline execution error', err?.message);
    } finally {
      setRunningSourceId(null);
    }
  };

  // Handler: Save Source
  const handleSaveSource = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingSource?.name || !editingSource?.baseUrl) {
      alert('Please provide Source Name and Base URL.');
      return;
    }

    try {
      await saveSource(editingSource);
      onShowToast('success', 'Source saved successfully');
      setShowSourceModal(false);
      setEditingSource(null);
      await loadData();
    } catch (err: any) {
      console.error('Error saving source:', err);
      onShowToast('error', 'Failed to save source', err?.message);
    }
  };

  // Handler: Delete Source
  const handleDeleteSource = async (sourceId: string, name: string) => {
    if (!confirm(`Are you sure you want to delete source portal '${name}'?`)) return;
    try {
      await deleteSource(sourceId);
      onShowToast('success', 'Source portal deleted');
      await loadData();
    } catch (err: any) {
      onShowToast('error', 'Failed to delete source');
    }
  };

  // Handler: Approve and Publish from Review Queue
  const handleApprovePublish = async (item: DiscoveredItem) => {
    try {
      const contentId = await approveAndPublishItem(item, userEmail);
      onShowToast('success', 'Notice Approved & Published!', `Created content doc #${contentId}`);
      setSelectedReviewItem(null);
      await loadData();
    } catch (err: any) {
      onShowToast('error', 'Failed to approve item', err?.message);
    }
  };

  // Handler: Reject
  const handleReject = async (item: DiscoveredItem) => {
    const reason = prompt('Enter rejection reason:', 'Incomplete notice or criteria not met');
    if (!reason) return;
    try {
      await rejectItem(item, reason, userEmail);
      onShowToast('info', 'Item rejected');
      setSelectedReviewItem(null);
      await loadData();
    } catch (err: any) {
      onShowToast('error', 'Failed to reject item', err?.message);
    }
  };

  // Handler: Mark Duplicate
  const handleMarkDuplicate = async (item: DiscoveredItem) => {
    const matchedId = prompt('Enter matched Content ID or Note:', 'Duplicate notice');
    if (!matchedId) return;
    try {
      await markDuplicateItem(item, matchedId, userEmail);
      onShowToast('info', 'Item routed to Duplicate Review');
      setSelectedReviewItem(null);
      await loadData();
    } catch (err: any) {
      onShowToast('error', 'Failed to mark duplicate', err?.message);
    }
  };

  // Handler: Edit in Smart Editor bridge
  const handleEditInSmartEditor = (item: DiscoveredItem) => {
    if (!item.extractedData) return;
    onEditInSmartEditor({
      ...item.extractedData,
      title: item.extractedData.title || item.title,
      sourceUrl: item.sourceUrl,
    });
  };

  // Handler: Test Gemini API Key
  const handleTestGeminiKey = async () => {
    if (!geminiSettings.geminiApiKey) {
      alert('Please enter a Gemini API Key first.');
      return;
    }
    setTestingApiKey(true);
    try {
      const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${geminiSettings.geminiModel || 'gemini-1.5-flash'}:generateContent?key=${encodeURIComponent(
        geminiSettings.geminiApiKey
      )}`;
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: 'Hello, respond with {"status": "ok"} only.' }] }],
          generationConfig: { responseMimeType: 'application/json' },
        }),
      });

      if (res.ok) {
        onShowToast('success', 'Gemini API Connected Successfully!', 'Key verified and responsive.');
      } else {
        const errText = await res.text();
        onShowToast('error', 'Gemini API Test Failed', `Status ${res.status}: ${errText.slice(0, 150)}`);
      }
    } catch (e: any) {
      onShowToast('error', 'Connection Error', e?.message);
    } finally {
      setTestingApiKey(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
        <div>
          <div className="flex items-center gap-2.5">
            <div className="p-2 bg-gradient-to-br from-[#159B76] to-emerald-700 text-white rounded-xl shadow-sm">
              <Cpu className="w-5 h-5" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-slate-900 tracking-tight flex items-center gap-2">
                Automated Ingestion &amp; Gemini Pipeline
                <span className="text-[11px] px-2 py-0.5 font-bold uppercase rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
                  AI v2.0
                </span>
              </h1>
              <p className="text-xs text-slate-500 mt-0.5">
                Safe discovery, zero-hallucination extraction, duplicate defense &amp; smart review queue
              </p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={loadData}
            disabled={loading}
            className="flex items-center gap-2 px-3.5 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition-all"
            title="Refresh All Data"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>
          <button
            onClick={() => {
              setEditingSource({
                enabled: true,
                sourceType: 'HTML',
                checkFrequency: 'daily',
                autoPublish: false,
                confidenceThreshold: 0.85,
                contentTypes: ['government_job'],
                status: 'healthy',
                allowedDomains: [],
              });
              setShowSourceModal(true);
            }}
            className="flex items-center gap-2 px-4 py-2 text-xs font-semibold text-white bg-[#159B76] hover:bg-[#128363] rounded-xl shadow-sm shadow-[#159B76]/25 transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>Add Source</span>
          </button>
        </div>
      </div>

      {/* Navigation Tabs */}
      <div className="bg-white border-b border-slate-200 rounded-2xl shadow-sm p-1.5 overflow-x-auto flex items-center gap-1">
        {[
          { id: 'sources', label: 'Sources', icon: <Database className="w-4 h-4" />, count: sources.length },
          { id: 'collection_queue', label: 'Collection Queue', icon: <Layers className="w-4 h-4" />, count: collectionQueue.length },
          { id: 'ai_queue', label: 'AI Processing', icon: <Sparkles className="w-4 h-4" />, count: aiQueue.length },
          { id: 'review_queue', label: 'Review Queue', icon: <CheckCircle className="w-4 h-4 text-emerald-600" />, count: reviewQueue.length, badgeColor: 'bg-emerald-500 text-white' },
          { id: 'duplicate_review', label: 'Duplicate Review', icon: <Copy className="w-4 h-4 text-amber-500" />, count: duplicateQueue.length, badgeColor: 'bg-amber-500 text-white' },
          { id: 'history', label: 'Import History', icon: <Clock className="w-4 h-4" />, count: historyQueue.length },
          { id: 'scheduler_settings', label: 'Scheduler & AI Settings', icon: <Settings className="w-4 h-4" /> },
          { id: 'activity_logs', label: 'Activity Logs', icon: <List className="w-4 h-4" />, count: logs.length },
        ].map((tab) => {
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as AutomationTab)}
              className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold whitespace-nowrap transition-all ${
                isActive
                  ? 'bg-[#159B76] text-white shadow-sm shadow-[#159B76]/25'
                  : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100'
              }`}
            >
              <span>{tab.icon}</span>
              <span>{tab.label}</span>
              {tab.count !== undefined && tab.count > 0 && (
                <span
                  className={`text-[10px] px-1.5 py-0.2 rounded-full font-bold ${
                    tab.badgeColor || (isActive ? 'bg-white/20 text-white' : 'bg-slate-200 text-slate-700')
                  }`}
                >
                  {tab.count}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* TAB 1: SOURCES */}
      {activeTab === 'sources' && (
        <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
          <div className="p-4 border-b border-slate-100 flex items-center justify-between">
            <h2 className="text-sm font-bold text-slate-800">
              Configured Source Portals ({sources.length})
            </h2>
            <span className="text-xs text-slate-500">
              Respectful crawler with anti-bot detection and safe failovers
            </span>
          </div>

          {sources.length === 0 ? (
            <div className="text-center py-12 px-4">
              <Database className="w-10 h-10 text-slate-300 mx-auto mb-3" />
              <h3 className="text-sm font-semibold text-slate-700">No official sources added yet</h3>
              <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
                Add government portals, recruitment commission websites, RSS feeds, or PDF indexes to begin automated discovery.
              </p>
              <button
                onClick={() => {
                  setEditingSource({
                    enabled: true,
                    sourceType: 'HTML',
                    checkFrequency: 'daily',
                    autoPublish: false,
                    confidenceThreshold: 0.85,
                    contentTypes: ['government_job'],
                    status: 'healthy',
                  });
                  setShowSourceModal(true);
                }}
                className="mt-4 inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold text-white bg-[#159B76] rounded-xl hover:bg-[#128363]"
              >
                <Plus className="w-4 h-4" /> Add First Source
              </button>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead>
                  <tr className="border-b border-slate-100 bg-slate-50/70 text-slate-500 font-bold uppercase tracking-wider">
                    <th className="py-3 px-4">Source Name</th>
                    <th className="py-3 px-3">Type</th>
                    <th className="py-3 px-3">Health Status</th>
                    <th className="py-3 px-3">Frequency</th>
                    <th className="py-3 px-3">Auto-Publish</th>
                    <th className="py-3 px-3 text-center">Items Found</th>
                    <th className="py-3 px-3 text-center">Published</th>
                    <th className="py-3 px-3 text-center">In Review</th>
                    <th className="py-3 px-3">Last Checked</th>
                    <th className="py-3 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {sources.map((src) => {
                    const isRunning = runningSourceId === src.id;
                    return (
                      <tr key={src.id} className="hover:bg-slate-50/50 transition-colors">
                        <td className="py-3.5 px-4 font-semibold text-slate-800">
                          <div className="flex items-center gap-2">
                            <span>{src.name}</span>
                            {!src.enabled && (
                              <span className="text-[10px] px-1.5 py-0.2 rounded bg-slate-100 text-slate-500">
                                Disabled
                              </span>
                            )}
                          </div>
                          <a
                            href={src.baseUrl}
                            target="_blank"
                            rel="noreferrer"
                            className="text-[11px] text-slate-400 hover:text-indigo-600 truncate max-w-xs block mt-0.5"
                          >
                            {src.baseUrl}
                          </a>
                        </td>
                        <td className="py-3 px-3">
                          <span className="px-2 py-0.5 rounded-full font-bold uppercase text-[10px] bg-indigo-50 text-indigo-700 border border-indigo-200">
                            {src.sourceType}
                          </span>
                        </td>
                        <td className="py-3 px-3">
                          {src.status === 'healthy' && (
                            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" /> Healthy
                            </span>
                          )}
                          {src.status === 'warning' && (
                            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                              <AlertTriangle className="w-3 h-3" /> Warning
                            </span>
                          )}
                          {src.status === 'blocked' && (
                            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold bg-rose-50 text-rose-700 border border-rose-200" title={src.lastError}>
                              <ShieldAlert className="w-3 h-3" /> Blocked (Manual)
                            </span>
                          )}
                          {src.status === 'failed' && (
                            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold bg-red-50 text-red-700 border border-red-200" title={src.lastError}>
                              <XCircle className="w-3 h-3" /> Failed
                            </span>
                          )}
                        </td>
                        <td className="py-3 px-3 capitalize text-slate-600 font-medium">
                          {src.checkFrequency.replace(/_/g, ' ')}
                        </td>
                        <td className="py-3 px-3">
                          {src.autoPublish ? (
                            <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700">
                              Enabled (≥{Math.round(src.confidenceThreshold * 100)}%)
                            </span>
                          ) : (
                            <span className="text-slate-400 font-medium text-[11px]">Off (Review Queue)</span>
                          )}
                        </td>
                        <td className="py-3 px-3 text-center font-bold text-slate-700">{src.itemsFound || 0}</td>
                        <td className="py-3 px-3 text-center font-bold text-emerald-700">{src.itemsPublished || 0}</td>
                        <td className="py-3 px-3 text-center font-bold text-amber-700">{src.itemsInReview || 0}</td>
                        <td className="py-3 px-3 text-[11px] text-slate-500">
                          {src.lastCheckedAt ? new Date(src.lastCheckedAt).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' }) : 'Never'}
                        </td>
                        <td className="py-3 px-4 text-right">
                          <div className="flex items-center justify-end gap-1.5">
                            <button
                              onClick={() => handleRunSource(src)}
                              disabled={isRunning}
                              className="p-1.5 rounded-lg text-emerald-700 bg-emerald-50 hover:bg-emerald-100 transition-colors"
                              title="Run Discovery Pipeline Now"
                            >
                              <Play className={`w-3.5 h-3.5 ${isRunning ? 'animate-spin' : ''}`} />
                            </button>
                            <button
                              onClick={() => {
                                setEditingSource(src);
                                setShowSourceModal(true);
                              }}
                              className="p-1.5 rounded-lg text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors"
                              title="Edit Source Config"
                            >
                              <Edit className="w-3.5 h-3.5" />
                            </button>
                            <button
                              onClick={() => handleDeleteSource(src.id, src.name)}
                              className="p-1.5 rounded-lg text-red-600 bg-red-50 hover:bg-red-100 transition-colors"
                              title="Delete Source"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {/* TAB 2: REVIEW QUEUE */}
      {activeTab === 'review_queue' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold text-slate-800">
              Extracted Notices Awaiting Verification ({reviewQueue.length})
            </h2>
            <span className="text-xs text-slate-500">
              Examine confidence ratings, validation warnings, and approve or customize in Smart Editor
            </span>
          </div>

          {reviewQueue.length === 0 ? (
            <div className="bg-white rounded-2xl border border-slate-200/80 p-12 text-center shadow-sm">
              <CheckCircle className="w-10 h-10 text-emerald-500 mx-auto mb-3" />
              <h3 className="text-sm font-semibold text-slate-700">Review Queue is completely clean!</h3>
              <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
                No notices currently waiting for review. You can run source pipelines or add new official sources.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-4">
              {reviewQueue.map((item) => {
                const confPercent = Math.round((item.overallConfidence ?? 0) * 100);
                const confColor =
                  confPercent >= 85
                    ? 'text-emerald-700 bg-emerald-50 border-emerald-200'
                    : confPercent >= 70
                    ? 'text-amber-700 bg-amber-50 border-amber-200'
                    : 'text-red-700 bg-red-50 border-red-200';

                const validation = item.validationResult || { isValid: true, criticalErrors: [], warnings: [] };

                return (
                  <div
                    key={item.id}
                    className="bg-white rounded-2xl border border-slate-200/80 p-5 shadow-sm hover:shadow-md transition-all space-y-4"
                  >
                    <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-3">
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-2 flex-wrap mb-1.5">
                          <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${confColor}`}>
                            Confidence: {confPercent}%
                          </span>
                          <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-slate-100 text-slate-700">
                            Source: {item.sourceName}
                          </span>
                          <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-indigo-50 text-indigo-700 uppercase">
                            {item.contentType || 'Job'}
                          </span>
                          {item.parentRecruitmentId && (
                            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-purple-50 text-purple-700 border border-purple-200">
                              Linked to Parent Recruitment #{item.parentRecruitmentId}
                            </span>
                          )}
                        </div>

                        <h3 className="text-base font-bold text-slate-900 leading-snug">
                          {item.extractedData?.title || item.title}
                        </h3>

                        <div className="flex items-center gap-4 text-xs text-slate-500 mt-2 flex-wrap">
                          <span>
                            <strong>Authority:</strong> {item.extractedData?.organization || 'Official'}
                          </span>
                          {item.extractedData?.totalVacancies !== undefined && (
                            <span>
                              <strong>Vacancies:</strong> {item.extractedData.totalVacancies}
                            </span>
                          )}
                          {item.extractedData?.applicationLastDate && (
                            <span>
                              <strong>Last Date:</strong> {item.extractedData.applicationLastDate}
                            </span>
                          )}
                          <a
                            href={item.sourceUrl}
                            target="_blank"
                            rel="noreferrer"
                            className="inline-flex items-center gap-1 text-indigo-600 hover:underline font-medium"
                          >
                            <span>Source Link</span>
                            <ExternalLink className="w-3 h-3" />
                          </a>
                        </div>
                      </div>

                      {/* Quick Action Buttons */}
                      <div className="flex items-center gap-2 flex-wrap shrink-0">
                        <button
                          onClick={() => handleApprovePublish(item)}
                          className="flex items-center gap-1.5 px-3 py-1.5 bg-[#159B76] hover:bg-[#128363] text-white text-xs font-semibold rounded-xl shadow-sm"
                        >
                          <Check className="w-3.5 h-3.5" />
                          <span>Approve &amp; Publish</span>
                        </button>
                        <button
                          onClick={() => handleEditInSmartEditor(item)}
                          className="flex items-center gap-1.5 px-3 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 text-xs font-semibold rounded-xl border border-indigo-200"
                        >
                          <Edit className="w-3.5 h-3.5" />
                          <span>Edit in Smart Editor</span>
                        </button>
                        <button
                          onClick={() => setSelectedReviewItem(item)}
                          className="p-1.5 rounded-xl bg-slate-100 text-slate-600 hover:bg-slate-200"
                          title="View Full Extraction Breakdown"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleReject(item)}
                          className="p-1.5 rounded-xl bg-red-50 text-red-600 hover:bg-red-100"
                          title="Reject"
                        >
                          <X className="w-4 h-4" />
                        </button>
                      </div>
                    </div>

                    {/* Warnings & Errors */}
                    {(validation.criticalErrors.length > 0 || validation.warnings.length > 0) && (
                      <div className="p-3 bg-amber-50/70 border border-amber-200/80 rounded-xl text-xs space-y-1">
                        {validation.criticalErrors.map((err, idx) => (
                          <div key={idx} className="flex items-center gap-1.5 text-red-700 font-semibold">
                            <XCircle className="w-3.5 h-3.5 shrink-0" />
                            <span>{err}</span>
                          </div>
                        ))}
                        {validation.warnings.map((warn, idx) => (
                          <div key={idx} className="flex items-center gap-1.5 text-amber-700 font-medium">
                            <AlertTriangle className="w-3.5 h-3.5 shrink-0" />
                            <span>{warn}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          )}
        </div>
      )}

      {/* TAB 3: DUPLICATE REVIEW */}
      {activeTab === 'duplicate_review' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold text-slate-800">
              Potential Duplicate Notices ({duplicateQueue.length})
            </h2>
            <span className="text-xs text-slate-500">
              Matches detected based on advertisement numbers, normalized titles, and content fingerprints
            </span>
          </div>

          {duplicateQueue.length === 0 ? (
            <div className="bg-white rounded-2xl border border-slate-200/80 p-12 text-center shadow-sm">
              <Check className="w-10 h-10 text-emerald-500 mx-auto mb-3" />
              <h3 className="text-sm font-semibold text-slate-700">No duplicate notices in queue</h3>
              <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
                All candidates are unique recruitment records.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-4">
              {duplicateQueue.map((item) => (
                <div key={item.id} className="bg-white rounded-2xl border border-slate-200/80 p-5 shadow-sm space-y-3">
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-100 text-amber-800">
                          {item.duplicateCheckResult?.matchReason || 'Duplicate Match'}
                        </span>
                        <span className="text-xs text-slate-400">
                          Similarity: {Math.round((item.duplicateCheckResult?.similarityScore || 0) * 100)}%
                        </span>
                      </div>
                      <h4 className="text-sm font-bold text-slate-900">{item.title}</h4>
                      <p className="text-xs text-slate-500 mt-1">
                        Matched with: <strong>{item.duplicateCheckResult?.matchedTitle || item.duplicateCheckResult?.matchedItemId}</strong>
                      </p>
                    </div>

                    <div className="flex items-center gap-2">
                      <button
                        onClick={async () => {
                          const updated = { ...item, status: 'REVIEW' as QueueItemStatus };
                          await saveQueueItem(updated);
                          onShowToast('info', 'Moved to Review Queue');
                          await loadData();
                        }}
                        className="px-3 py-1.5 text-xs font-semibold bg-emerald-50 text-emerald-700 hover:bg-emerald-100 rounded-xl"
                      >
                        Ignore &amp; Send to Review
                      </button>
                      <button
                        onClick={async () => {
                          await deleteQueueItem(item.id);
                          onShowToast('success', 'Duplicate dismissed and purged');
                          await loadData();
                        }}
                        className="p-1.5 text-red-600 bg-red-50 hover:bg-red-100 rounded-xl"
                        title="Delete from Queue"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* TAB 4: COLLECTION & AI QUEUE */}
      {(activeTab === 'collection_queue' || activeTab === 'ai_queue') && (
        <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
          <div className="p-4 border-b border-slate-100 flex items-center justify-between">
            <h2 className="text-sm font-bold text-slate-800">
              {activeTab === 'collection_queue' ? 'Newly Discovered Notices' : 'AI Processing Queue'}
            </h2>
          </div>
          <div className="p-8 text-center text-xs text-slate-500">
            {activeTab === 'collection_queue'
              ? `There are ${collectionQueue.length} notices discovered awaiting fetch and AI extraction.`
              : `There are ${aiQueue.length} items currently in processing.`}
          </div>
        </div>
      )}

      {/* TAB 5: SCHEDULER & AI SETTINGS */}
      {activeTab === 'scheduler_settings' && (
        <div className="bg-white rounded-2xl border border-slate-200/80 p-6 shadow-sm space-y-6 max-w-3xl">
          <div>
            <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-emerald-600" />
              <span>Google Gemini AI &amp; Extraction Settings</span>
            </h2>
            <p className="text-xs text-slate-500 mt-1">
              Configure server-side Gemini API credentials for structured normalization without hallucination
            </p>
          </div>

          <div className="space-y-4 pt-2 border-t border-slate-100">
            <div className="flex items-center justify-between">
              <div>
                <label className="text-xs font-bold text-slate-800">Enable Gemini Normalization</label>
                <p className="text-[11px] text-slate-500">
                  Automatically parse discovered notices into Notify Jobs schema
                </p>
              </div>
              <input
                type="checkbox"
                checked={geminiSettings.geminiEnabled}
                onChange={(e) => setGeminiSettings({ ...geminiSettings, geminiEnabled: e.target.checked })}
                className="w-4 h-4 accent-[#159B76] rounded"
              />
            </div>

            <div>
              <label className="text-xs font-bold text-slate-800 block mb-1">
                Gemini API Key (Server / Admin Stored)
              </label>
              <div className="flex gap-2">
                <input
                  type="password"
                  placeholder="AIzaSy..."
                  value={geminiSettings.geminiApiKey}
                  onChange={(e) => setGeminiSettings({ ...geminiSettings, geminiApiKey: e.target.value })}
                  className="flex-1 px-3 py-2 text-xs border border-slate-200 rounded-xl font-mono focus:outline-none focus:ring-2 focus:ring-[#159B76]"
                />
                <button
                  type="button"
                  onClick={handleTestGeminiKey}
                  disabled={testingApiKey}
                  className="px-3 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl"
                >
                  {testingApiKey ? 'Testing...' : 'Test Connection'}
                </button>
              </div>
              <p className="text-[11px] text-slate-400 mt-1">
                Never shipped in mobile app or exposed to public clients.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="text-xs font-bold text-slate-800 block mb-1">Gemini Model</label>
                <select
                  value={geminiSettings.geminiModel}
                  onChange={(e) => setGeminiSettings({ ...geminiSettings, geminiModel: e.target.value })}
                  className="w-full px-3 py-2 text-xs border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#159B76]"
                >
                  <option value="gemini-1.5-flash">Gemini 1.5 Flash (Fast, Recommended)</option>
                  <option value="gemini-2.5-flash">Gemini 2.5 Flash (Ultra Fast)</option>
                  <option value="gemini-1.5-pro">Gemini 1.5 Pro (Deep Document Parsing)</option>
                </select>
              </div>

              <div>
                <label className="text-xs font-bold text-slate-800 block mb-1">
                  Default Confidence Threshold ({Math.round(geminiSettings.confidenceThreshold * 100)}%)
                </label>
                <input
                  type="range"
                  min="0.5"
                  max="0.99"
                  step="0.01"
                  value={geminiSettings.confidenceThreshold}
                  onChange={(e) => setGeminiSettings({ ...geminiSettings, confidenceThreshold: Number(e.target.value) })}
                  className="w-full accent-[#159B76]"
                />
              </div>
            </div>

            <button
              onClick={async () => {
                await saveGeminiSettings(geminiSettings);
                onShowToast('success', 'Gemini settings saved successfully');
              }}
              className="px-4 py-2 text-xs font-semibold text-white bg-[#159B76] hover:bg-[#128363] rounded-xl shadow-sm"
            >
              Save Settings
            </button>
          </div>
        </div>
      )}

      {/* TAB 6: ACTIVITY LOGS */}
      {activeTab === 'activity_logs' && (
        <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden space-y-4">
          <div className="p-4 border-b border-slate-100 flex items-center justify-between">
            <h2 className="text-sm font-bold text-slate-800">Pipeline Activity Logs ({logs.length})</h2>
            <select
              value={logFilter}
              onChange={(e) => setLogFilter(e.target.value)}
              className="text-xs px-2.5 py-1.5 border border-slate-200 rounded-xl"
            >
              <option value="all">All Severities</option>
              <option value="error">Errors &amp; Blocked</option>
              <option value="warning">Warnings</option>
              <option value="success">Success / Published</option>
            </select>
          </div>

          <div className="divide-y divide-slate-100 max-h-[600px] overflow-y-auto">
            {logs
              .filter((l) => logFilter === 'all' || l.severity === logFilter)
              .map((l) => (
                <div key={l.id} className="p-4 hover:bg-slate-50 flex items-start gap-3 text-xs">
                  <div className="mt-0.5">
                    {l.severity === 'success' && <CheckCircle className="w-4 h-4 text-emerald-600" />}
                    {l.severity === 'error' && <XCircle className="w-4 h-4 text-red-600" />}
                    {l.severity === 'warning' && <AlertTriangle className="w-4 h-4 text-amber-600" />}
                    {l.severity === 'info' && <Clock className="w-4 h-4 text-indigo-600" />}
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="font-semibold text-slate-800">{l.message}</p>
                    <div className="flex items-center gap-3 text-[11px] text-slate-400 mt-1">
                      <span>{new Date(l.timestamp).toLocaleTimeString()}</span>
                      {l.sourceName && <span>Source: {l.sourceName}</span>}
                      <span className="capitalize">{l.eventType.replace(/_/g, ' ')}</span>
                    </div>
                  </div>
                </div>
              ))}
          </div>
        </div>
      )}

      {/* MODAL: ADD / EDIT SOURCE */}
      {showSourceModal && editingSource && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-xl w-full p-6 shadow-xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-base font-bold text-slate-900">
                {editingSource.id ? 'Edit Source Portal' : 'Add Official Recruitment Source'}
              </h3>
              <button
                onClick={() => setShowSourceModal(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveSource} className="space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Source Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. UPSC Official Portal"
                  value={editingSource.name || ''}
                  onChange={(e) => setEditingSource({ ...editingSource, name: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-200 rounded-xl"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Base URL *</label>
                  <input
                    type="url"
                    required
                    placeholder="https://upsc.gov.in"
                    value={editingSource.baseUrl || ''}
                    onChange={(e) => setEditingSource({ ...editingSource, baseUrl: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Source Type</label>
                  <select
                    value={editingSource.sourceType || 'HTML'}
                    onChange={(e) => setEditingSource({ ...editingSource, sourceType: e.target.value as SourceType })}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl"
                  >
                    <option value="HTML">HTML Public Listing</option>
                    <option value="RSS">RSS / Atom Feed</option>
                    <option value="API">Official JSON API</option>
                    <option value="PDF_INDEX">Public PDF Index</option>
                    <option value="MANUAL">Manual Batch Import</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Listing Crawl Path / Sub-URL</label>
                <input
                  type="text"
                  placeholder="recruitment/advertisements or /notices"
                  value={editingSource.crawlPath || ''}
                  onChange={(e) => setEditingSource({ ...editingSource, crawlPath: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-200 rounded-xl"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Default Organization</label>
                  <input
                    type="text"
                    placeholder="Union Public Service Commission"
                    value={editingSource.defaultOrganization || ''}
                    onChange={(e) => setEditingSource({ ...editingSource, defaultOrganization: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Check Frequency</label>
                  <select
                    value={editingSource.checkFrequency || 'daily'}
                    onChange={(e) => setEditingSource({ ...editingSource, checkFrequency: e.target.value as CheckFrequency })}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl"
                  >
                    <option value="manual">Manual Only</option>
                    <option value="hourly">Hourly</option>
                    <option value="every_3_hours">Every 3 Hours</option>
                    <option value="every_6_hours">Every 6 Hours</option>
                    <option value="daily">Daily</option>
                  </select>
                </div>
              </div>

              <div className="p-3 bg-slate-50 border border-slate-200 rounded-xl space-y-2">
                <div className="flex items-center justify-between">
                  <div>
                    <span className="font-bold text-slate-800">Auto-Publish</span>
                    <p className="text-[11px] text-slate-500">
                      Only publish when confidence meets threshold &amp; 0 validation errors
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={editingSource.autoPublish || false}
                    onChange={(e) => setEditingSource({ ...editingSource, autoPublish: e.target.checked })}
                    className="w-4 h-4 accent-[#159B76] rounded"
                  />
                </div>

                {editingSource.autoPublish && (
                  <div>
                    <label className="text-[11px] font-semibold text-slate-700 block mb-1">
                      Required Confidence Threshold ({Math.round((editingSource.confidenceThreshold || 0.85) * 100)}%)
                    </label>
                    <input
                      type="range"
                      min="0.70"
                      max="0.99"
                      step="0.01"
                      value={editingSource.confidenceThreshold || 0.85}
                      onChange={(e) => setEditingSource({ ...editingSource, confidenceThreshold: Number(e.target.value) })}
                      className="w-full accent-[#159B76]"
                    />
                  </div>
                )}
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setShowSourceModal(false)}
                  className="px-4 py-2 text-slate-600 bg-slate-100 rounded-xl font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-white bg-[#159B76] hover:bg-[#128363] rounded-xl font-semibold shadow-sm"
                >
                  Save Source Portal
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL: EXTRACTED DETAILS COMPARISON */}
      {selectedReviewItem && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-4xl w-full p-6 shadow-xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-base font-bold text-slate-900">
                Extraction &amp; Validation Inspection
              </h3>
              <button
                onClick={() => setSelectedReviewItem(null)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {/* Left: Original Source */}
              <div className="space-y-2 border border-slate-200 rounded-xl p-3 bg-slate-50 text-xs">
                <h4 className="font-bold text-slate-800 flex items-center gap-1.5">
                  <Database className="w-4 h-4 text-slate-600" /> Original Source Notice
                </h4>
                <p className="text-[11px] text-slate-500 break-all">
                  URL: <a href={selectedReviewItem.sourceUrl} target="_blank" rel="noreferrer" className="text-indigo-600 underline">{selectedReviewItem.sourceUrl}</a>
                </p>
                <div className="max-h-60 overflow-y-auto p-2 bg-white rounded border border-slate-200 font-mono text-[10px] text-slate-600 whitespace-pre-wrap">
                  {selectedReviewItem.rawContent || 'No raw content preview'}
                </div>
              </div>

              {/* Right: Extracted Structured Data */}
              <div className="space-y-2 border border-slate-200 rounded-xl p-3 text-xs">
                <h4 className="font-bold text-slate-800 flex items-center gap-1.5">
                  <Sparkles className="w-4 h-4 text-emerald-600" /> Extracted Notify Jobs Schema
                </h4>
                <div className="space-y-1.5 text-slate-700">
                  <p><strong>Title:</strong> {selectedReviewItem.extractedData?.title}</p>
                  <p><strong>Organization:</strong> {selectedReviewItem.extractedData?.organization}</p>
                  <p><strong>Vacancies:</strong> {selectedReviewItem.extractedData?.totalVacancies || 'N/A'}</p>
                  <p><strong>Last Date:</strong> {selectedReviewItem.extractedData?.applicationLastDate || 'N/A'}</p>
                  <p><strong>Apply Link:</strong> {selectedReviewItem.extractedData?.applyUrl || 'None'}</p>
                  <p><strong>Posts:</strong> {selectedReviewItem.extractedData?.posts?.length || 0} post(s)</p>
                </div>
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
              <button
                onClick={() => setSelectedReviewItem(null)}
                className="px-4 py-2 text-slate-600 bg-slate-100 rounded-xl font-semibold text-xs"
              >
                Close
              </button>
              <button
                onClick={() => handleEditInSmartEditor(selectedReviewItem)}
                className="px-4 py-2 text-indigo-700 bg-indigo-50 border border-indigo-200 rounded-xl font-semibold text-xs"
              >
                Edit in Smart Editor
              </button>
              <button
                onClick={() => handleApprovePublish(selectedReviewItem)}
                className="px-4 py-2 text-white bg-[#159B76] hover:bg-[#128363] rounded-xl font-semibold text-xs shadow-sm"
              >
                Approve &amp; Publish
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
