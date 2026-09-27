import React, { useState } from 'react';
import {
  Plus,
  Trash2,
  Copy,
  ChevronDown,
  ChevronUp,
  Layers,
  Calculator,
  AlertCircle,
  Briefcase,
  ArrowUp,
  ArrowDown,
  Info,
} from 'lucide-react';
import { PostItem, VacancyBreakup, Category } from '../../types';
import { AdminInput } from '../common/AdminInput';
import { AdminSelect } from '../common/AdminSelect';
import { AdminButton } from '../common/AdminButton';

interface PostVacancyBuilderProps {
  mode: 'simple' | 'detailed';
  onModeChange: (newMode: 'simple' | 'detailed') => void;
  posts: PostItem[];
  onPostsChange: (posts: PostItem[]) => void;
  simpleTotalVacancies: string | number;
  onSimpleTotalChange: (total: string | number) => void;
  simpleBreakup: VacancyBreakup;
  onSimpleBreakupChange: (breakup: VacancyBreakup) => void;
  categories: Category[];
  defaultDepartment?: string;
  defaultLocation?: string;
  defaultPayLevel?: string;
  defaultQualification?: string;
  defaultMinAge?: string | number;
  defaultMaxAge?: string | number;
}

const QUALIFICATION_OPTIONS = [
  { value: '', label: 'Inherit Default Recruitment Qualification' },
  { value: '10th', label: '10th Pass / Matriculation' },
  { value: '12th', label: '12th Pass / Intermediate' },
  { value: 'ITI', label: 'ITI (Industrial Training)' },
  { value: 'Diploma', label: 'Diploma' },
  { value: 'Graduate', label: 'Graduate (Bachelor Degree)' },
  { value: 'B.E.', label: 'B.E. (Bachelor of Engineering)' },
  { value: 'B.Tech', label: 'B.Tech (Bachelor of Technology)' },
  { value: 'Post Graduate', label: 'Post Graduate (Master Degree)' },
  { value: 'Professional Qualification', label: 'Professional Qualification (CA, MBBS, LLB, etc.)' },
  { value: 'Other', label: 'Other Specified Qualification' },
];

const GROUP_OPTIONS = [
  { value: '', label: 'Select Group' },
  { value: 'Group A', label: 'Group A' },
  { value: 'Group B Gazetted', label: 'Group B Gazetted' },
  { value: 'Group B Non-Gazetted', label: 'Group B Non-Gazetted' },
  { value: 'Group C', label: 'Group C' },
  { value: 'Group D', label: 'Group D' },
];

export const calculateVacancyTotal = (v: Partial<VacancyBreakup>): number => {
  const ur = Math.max(0, parseInt(String(v.ur || 0), 10) || 0);
  const obc = Math.max(0, parseInt(String(v.obc || 0), 10) || 0);
  const ews = Math.max(0, parseInt(String(v.ews || 0), 10) || 0);
  const sc = Math.max(0, parseInt(String(v.sc || 0), 10) || 0);
  const st = Math.max(0, parseInt(String(v.st || 0), 10) || 0);
  const pwbd = Math.max(0, parseInt(String(v.pwbd || 0), 10) || 0);
  const esm = Math.max(0, parseInt(String(v.esm || 0), 10) || 0);
  const msp = Math.max(0, parseInt(String(v.msp || 0), 10) || 0);
  const other = Math.max(0, parseInt(String(v.other || 0), 10) || 0);
  return ur + obc + ews + sc + st + pwbd + esm + msp + other;
};

export const PostVacancyBuilder: React.FC<PostVacancyBuilderProps> = ({
  mode,
  onModeChange,
  posts,
  onPostsChange,
  simpleTotalVacancies,
  onSimpleTotalChange,
  simpleBreakup,
  onSimpleBreakupChange,
  categories,
  defaultDepartment = '',
  defaultLocation = '',
  defaultPayLevel = '',
  defaultQualification = '',
  defaultMinAge = '',
  defaultMaxAge = '',
}) => {
  const [collapsedPosts, setCollapsedPosts] = useState<Record<string, boolean>>({});

  // Compute Overall Total from Posts
  const overallTotalDetailed = posts.reduce((sum, p) => sum + (p.vacancies.total || 0), 0);

  // Compute Simple Mode Breakup Total (if any is entered)
  const simpleBreakupSum = calculateVacancyTotal(simpleBreakup);

  const togglePostCollapse = (id: string) => {
    setCollapsedPosts((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  const handleAddPost = () => {
    const newId = `post_${Date.now()}`;
    const newPost: PostItem = {
      id: newId,
      postName: '',
      postCode: '',
      group: '',
      cadre: '',
      department: defaultDepartment,
      categoryId: '',
      categoryName: '',
      qualification: defaultQualification,
      qualificationDetails: '',
      desirableQualification: '',
      location: defaultLocation,
      jobType: '',
      payLevel: defaultPayLevel,
      payScale: '',
      salaryMin: '',
      salaryMax: '',
      salaryText: '',
      ageMin: defaultMinAge,
      ageMax: defaultMaxAge,
      maleMaxAge: '',
      femaleMaxAge: '',
      ageAsOn: '',
      ageRelaxation: '',
      vacancies: {
        ur: 0,
        obc: 0,
        ews: 0,
        sc: 0,
        st: 0,
        pwbd: 0,
        esm: 0,
        msp: 0,
        other: 0,
        total: 0,
      },
    };
    onPostsChange([...posts, newPost]);
    setCollapsedPosts((prev) => ({ ...prev, [newId]: false }));
  };

  const handleDuplicatePost = (idx: number) => {
    const source = posts[idx];
    const newId = `post_${Date.now()}`;
    const duplicated: PostItem = {
      ...source,
      id: newId,
      postName: source.postName ? `${source.postName} (Copy)` : 'New Post (Copy)',
      vacancies: { ...source.vacancies },
    };
    const nextPosts = [...posts];
    nextPosts.splice(idx + 1, 0, duplicated);
    onPostsChange(nextPosts);
    setCollapsedPosts((prev) => ({ ...prev, [newId]: false }));
  };

  const handleDeletePost = (idx: number) => {
    onPostsChange(posts.filter((_, i) => i !== idx));
  };

  const handleMovePost = (idx: number, direction: 'up' | 'down') => {
    const targetIdx = direction === 'up' ? idx - 1 : idx + 1;
    if (targetIdx < 0 || targetIdx >= posts.length) return;
    const nextPosts = [...posts];
    const temp = nextPosts[idx];
    nextPosts[idx] = nextPosts[targetIdx];
    nextPosts[targetIdx] = temp;
    onPostsChange(nextPosts);
  };

  const handleUpdatePostField = (idx: number, field: keyof PostItem, value: any) => {
    const updated = [...posts];
    updated[idx] = {
      ...updated[idx],
      [field]: value,
    };
    if (field === 'categoryId') {
      const found = categories.find((c) => c.id === value || c.slug === value);
      updated[idx].categoryName = found?.name || '';
    }
    onPostsChange(updated);
  };

  const handleUpdateVacancyField = (idx: number, catKey: keyof VacancyBreakup, rawVal: string) => {
    const parsed = Math.max(0, parseInt(rawVal.replace(/[^0-9]/g, ''), 10) || 0);
    const updated = [...posts];
    const post = { ...updated[idx] };
    const vacancies = { ...post.vacancies, [catKey]: parsed };
    vacancies.total = calculateVacancyTotal(vacancies);
    post.vacancies = vacancies;
    updated[idx] = post;
    onPostsChange(updated);
  };

  const handleUpdateSimpleBreakup = (catKey: keyof VacancyBreakup, rawVal: string) => {
    const parsed = Math.max(0, parseInt(rawVal.replace(/[^0-9]/g, ''), 10) || 0);
    const next = { ...simpleBreakup, [catKey]: parsed };
    next.total = calculateVacancyTotal(next);
    onSimpleBreakupChange(next);
    if (next.total > 0 && (!simpleTotalVacancies || Number(simpleTotalVacancies) === 0)) {
      onSimpleTotalChange(next.total);
    }
  };

  return (
    <div className="space-y-4">
      {/* Mode Switcher & Summary Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-3.5 bg-slate-50 border border-slate-200 rounded-xl">
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold text-slate-700">Vacancy Entry Mode:</span>
          <div className="inline-flex rounded-lg border border-slate-200 bg-white p-0.5 shadow-2xs">
            <button
              type="button"
              onClick={() => onModeChange('detailed')}
              className={`px-3 py-1 text-xs font-bold rounded-md transition-colors ${
                mode === 'detailed'
                  ? 'bg-[#159B76] text-white shadow-2xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              Detailed (Post-wise)
            </button>
            <button
              type="button"
              onClick={() => onModeChange('simple')}
              className={`px-3 py-1 text-xs font-bold rounded-md transition-colors ${
                mode === 'simple'
                  ? 'bg-[#159B76] text-white shadow-2xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              Simple (Total Only)
            </button>
          </div>
        </div>

        {/* Live Auto Totals Banner */}
        <div className="flex items-center gap-2 text-xs">
          {mode === 'detailed' ? (
            <div className="flex items-center gap-2 font-bold px-3 py-1 rounded-lg bg-emerald-50 text-[#159B76] border border-emerald-200">
              <Calculator className="w-3.5 h-3.5" />
              <span>Total Posts: {posts.length}</span>
              <span className="text-emerald-300">|</span>
              <span>Total Vacancies: {overallTotalDetailed}</span>
              <span className="text-[10px] font-normal text-emerald-600">(Auto-calculated)</span>
            </div>
          ) : (
            <div className="flex items-center gap-1.5 font-bold px-3 py-1 rounded-lg bg-slate-100 text-slate-700 border border-slate-200">
              <Calculator className="w-3.5 h-3.5 text-slate-500" />
              <span>Total Vacancies: {simpleTotalVacancies || simpleBreakupSum || '0'}</span>
            </div>
          )}
        </div>
      </div>

      {/* SIMPLE MODE CONTENT */}
      {mode === 'simple' && (
        <div className="p-4 bg-white border border-slate-200 rounded-xl space-y-4">
          <div className="max-w-xs">
            <AdminInput
              label="Overall Total Vacancies"
              required
              type="number"
              value={String(simpleTotalVacancies ?? '')}
              onChange={(e) => onSimpleTotalChange(e.target.value)}
              placeholder="e.g. 50"
            />
          </div>

          <div className="pt-2 border-t border-slate-100">
            <span className="block text-xs font-bold text-slate-700 mb-2">
              Category-wise Breakup (Optional)
            </span>
            <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-9 gap-2">
              {(['ur', 'obc', 'ews', 'sc', 'st', 'pwbd', 'esm', 'msp', 'other'] as (keyof VacancyBreakup)[]).map(
                (catKey) => (
                  <div key={catKey}>
                    <label className="block text-[11px] font-bold text-slate-600 uppercase mb-1">
                      {catKey}
                    </label>
                    <input
                      type="text"
                      inputMode="numeric"
                      value={simpleBreakup[catKey] ?? 0}
                      onChange={(e) => handleUpdateSimpleBreakup(catKey, e.target.value)}
                      className="w-full text-xs text-center font-bold px-2 py-1.5 rounded-lg border border-slate-200 bg-white focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76]"
                    />
                  </div>
                )
              )}
            </div>
          </div>
        </div>
      )}

      {/* DETAILED MODE CONTENT */}
      {mode === 'detailed' && (
        <div className="space-y-3">
          {posts.length === 0 ? (
            <div className="text-center py-8 px-4 bg-slate-50 border border-dashed border-slate-300 rounded-xl">
              <Briefcase className="w-8 h-8 text-slate-400 mx-auto mb-2" />
              <p className="text-xs font-bold text-slate-700">No Posts Added Yet</p>
              <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
                Government recruitments often have multiple designations (e.g. Agriculture Officer, Assistant). Add individual posts below.
              </p>
              <div className="mt-3">
                <AdminButton
                  type="button"
                  variant="primary"
                  size="sm"
                  icon={<Plus className="w-4 h-4" />}
                  onClick={handleAddPost}
                >
                  Add First Post
                </AdminButton>
              </div>
            </div>
          ) : (
            posts.map((post, idx) => {
              const isCollapsed = Boolean(collapsedPosts[post.id]);
              const postTotal = post.vacancies?.total ?? calculateVacancyTotal(post.vacancies);

              return (
                <div
                  key={post.id}
                  className="bg-white border border-slate-200/90 rounded-xl shadow-2xs overflow-hidden transition-all"
                >
                  {/* Card Header Bar */}
                  <div className="px-4 py-2.5 bg-slate-50/80 border-b border-slate-100 flex items-center justify-between gap-3">
                    <div className="flex items-center gap-2.5 min-w-0">
                      <span className="w-6 h-6 rounded-md bg-[#159B76]/10 text-[#159B76] text-xs font-bold flex items-center justify-center shrink-0">
                        {idx + 1}
                      </span>
                      <span className="text-xs font-bold text-slate-900 truncate">
                        {post.postName.trim() || `Untitled Post #${idx + 1}`}
                      </span>
                      {post.group && (
                        <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-50 text-amber-800 border border-amber-200 shrink-0">
                          {post.group}
                        </span>
                      )}
                      {post.postCode && (
                        <span className="px-2 py-0.5 rounded text-[10px] font-mono font-medium bg-slate-100 text-slate-600 shrink-0">
                          {post.postCode}
                        </span>
                      )}
                      {post.payLevel && (
                        <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200 shrink-0">
                          {post.payLevel}
                        </span>
                      )}
                    </div>

                    <div className="flex items-center gap-1.5 shrink-0">
                      {/* Post Total Badge */}
                      <span className="px-2.5 py-0.5 rounded-full text-[11px] font-black bg-emerald-50 text-[#159B76] border border-emerald-200">
                        {postTotal} {postTotal === 1 ? 'Vacancy' : 'Vacancies'}
                      </span>

                      {/* Controls */}
                      <button
                        type="button"
                        disabled={idx === 0}
                        onClick={() => handleMovePost(idx, 'up')}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 disabled:opacity-20 hover:bg-slate-200/60"
                        title="Move Up"
                      >
                        <ArrowUp className="w-3.5 h-3.5" />
                      </button>
                      <button
                        type="button"
                        disabled={idx === posts.length - 1}
                        onClick={() => handleMovePost(idx, 'down')}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 disabled:opacity-20 hover:bg-slate-200/60"
                        title="Move Down"
                      >
                        <ArrowDown className="w-3.5 h-3.5" />
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDuplicatePost(idx)}
                        className="p-1.5 rounded-lg text-indigo-600 hover:bg-indigo-50"
                        title="Duplicate Post"
                      >
                        <Copy className="w-3.5 h-3.5" />
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDeletePost(idx)}
                        className="p-1.5 rounded-lg text-rose-600 hover:bg-rose-50"
                        title="Delete Post"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                      <button
                        type="button"
                        onClick={() => togglePostCollapse(post.id)}
                        className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-200/60"
                        title={isCollapsed ? 'Expand' : 'Collapse'}
                      >
                        {isCollapsed ? (
                          <ChevronDown className="w-4 h-4" />
                        ) : (
                          <ChevronUp className="w-4 h-4" />
                        )}
                      </button>
                    </div>
                  </div>

                  {/* Collapsible Body */}
                  {!isCollapsed && (
                    <div className="p-4 space-y-4">
                      {/* Row 1: Designation, Code, Group, Cadre */}
                      <div className="grid grid-cols-1 sm:grid-cols-4 gap-3">
                        <div className="sm:col-span-2">
                          <AdminInput
                            label="Post / Designation Name *"
                            required
                            value={post.postName}
                            onChange={(e) => handleUpdatePostField(idx, 'postName', e.target.value)}
                            placeholder="e.g. Agriculture Officer, Agriculture Assistant"
                          />
                        </div>
                        <AdminInput
                          label="Post Code"
                          value={post.postCode || ''}
                          onChange={(e) => handleUpdatePostField(idx, 'postCode', e.target.value)}
                          placeholder="e.g. AGRI-01, 102/26"
                        />
                        <AdminSelect
                          label="Classification / Group"
                          value={post.group || ''}
                          onChange={(e) => handleUpdatePostField(idx, 'group', e.target.value)}
                          options={GROUP_OPTIONS}
                        />
                      </div>

                      {/* Row 2: Cadre, Department, Location, Category */}
                      <div className="grid grid-cols-1 sm:grid-cols-4 gap-3">
                        <AdminInput
                          label="Cadre / Sub-Department (Optional)"
                          value={post.cadre || ''}
                          onChange={(e) => handleUpdatePostField(idx, 'cadre', e.target.value)}
                          placeholder="e.g. Technical Cadre, Field Cadre"
                        />
                        <AdminInput
                          label="Department (Optional)"
                          value={post.department || ''}
                          onChange={(e) => handleUpdatePostField(idx, 'department', e.target.value)}
                          placeholder={defaultDepartment ? `Default: ${defaultDepartment}` : 'e.g. Directorate of Agriculture'}
                        />
                        <AdminInput
                          label="Job Location (Optional)"
                          value={post.location || ''}
                          onChange={(e) => handleUpdatePostField(idx, 'location', e.target.value)}
                          placeholder={defaultLocation ? `Default: ${defaultLocation}` : 'e.g. Port Blair / South Andaman'}
                        />
                        <AdminSelect
                          label="Post Category (Optional)"
                          value={post.categoryId || ''}
                          onChange={(e) => handleUpdatePostField(idx, 'categoryId', e.target.value)}
                          options={[
                            { value: '', label: 'General / No Override' },
                            ...categories.map((c) => ({
                              value: c.id,
                              label: c.name,
                            })),
                          ]}
                        />
                      </div>

                      {/* Row 3: Essential Qualification & Desirable Qualification */}
                      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                        <AdminSelect
                          label="Essential Qualification"
                          value={post.qualification || ''}
                          onChange={(e) => handleUpdatePostField(idx, 'qualification', e.target.value)}
                          options={QUALIFICATION_OPTIONS}
                        />
                        <AdminInput
                          label="Qualification Details / Degree"
                          value={post.qualificationDetails || ''}
                          onChange={(e) =>
                            handleUpdatePostField(idx, 'qualificationDetails', e.target.value)
                          }
                          placeholder="e.g. B.Sc. in Agriculture with 55% marks"
                        />
                        <AdminInput
                          label="Desirable Qualification (Optional)"
                          value={post.desirableQualification || ''}
                          onChange={(e) =>
                            handleUpdatePostField(idx, 'desirableQualification', e.target.value)
                          }
                          placeholder="e.g. 2 years experience in organic farming"
                        />
                      </div>

                      {/* Row 4: Salary & Age Overrides */}
                      <div className="grid grid-cols-1 sm:grid-cols-4 gap-3">
                        <AdminInput
                          label="Pay Level (Optional)"
                          value={post.payLevel || ''}
                          onChange={(e) => handleUpdatePostField(idx, 'payLevel', e.target.value)}
                          placeholder={defaultPayLevel ? `Default: ${defaultPayLevel}` : 'e.g. Level 6'}
                        />
                        <AdminInput
                          label="Pay Scale (Optional)"
                          value={post.payScale || ''}
                          onChange={(e) => handleUpdatePostField(idx, 'payScale', e.target.value)}
                          placeholder="e.g. ₹35,400 - ₹1,12,400"
                        />
                        <AdminInput
                          label="Min Age (Optional)"
                          type="number"
                          value={String(post.ageMin ?? '')}
                          onChange={(e) => handleUpdatePostField(idx, 'ageMin', e.target.value)}
                          placeholder={defaultMinAge ? `Default: ${defaultMinAge}` : '18'}
                        />
                        <AdminInput
                          label="Max Age (Optional)"
                          type="number"
                          value={String(post.ageMax ?? '')}
                          onChange={(e) => handleUpdatePostField(idx, 'ageMax', e.target.value)}
                          placeholder={defaultMaxAge ? `Default: ${defaultMaxAge}` : '30'}
                        />
                      </div>

                      {/* Row 5: Vacancy Category Breakup & Strict Auto Total */}
                      <div className="p-3.5 bg-slate-50 rounded-xl border border-slate-200/80">
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-xs font-bold text-slate-800 flex items-center gap-1.5">
                            <Layers className="w-3.5 h-3.5 text-[#159B76]" />
                            Category-wise Vacancy Breakup
                          </span>
                          <span className="text-[11px] text-slate-500 font-medium">
                            Live auto-sum (negative numbers rejected)
                          </span>
                        </div>

                        <div className="grid grid-cols-2 sm:grid-cols-5 md:grid-cols-10 gap-2">
                          {(
                            [
                              'ur',
                              'obc',
                              'ews',
                              'sc',
                              'st',
                              'pwbd',
                              'esm',
                              'msp',
                              'other',
                            ] as (keyof VacancyBreakup)[]
                          ).map((catKey) => (
                            <div key={catKey}>
                              <label className="block text-[11px] font-bold text-slate-600 uppercase mb-1">
                                {catKey}
                              </label>
                              <input
                                type="text"
                                inputMode="numeric"
                                value={post.vacancies[catKey] ?? 0}
                                onChange={(e) =>
                                  handleUpdateVacancyField(idx, catKey, e.target.value)
                                }
                                className="w-full text-xs text-center font-bold px-2 py-1.5 rounded-lg border border-slate-200 bg-white focus:outline-none focus:ring-2 focus:ring-[#159B76]/20 focus:border-[#159B76]"
                              />
                            </div>
                          ))}

                          {/* Strictly Read-Only Auto Calculated Total */}
                          <div>
                            <label className="block text-[11px] font-bold text-emerald-800 uppercase mb-1">
                              Post Total
                            </label>
                            <div
                              className="w-full text-xs text-center font-black px-2 py-1.5 rounded-lg border border-emerald-300 bg-emerald-50 text-[#159B76] shadow-2xs select-none"
                              title="Auto-calculated sum"
                            >
                              {postTotal}
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              );
            })
          )}

          {/* Add Post Button */}
          <div className="pt-2 flex justify-start">
            <AdminButton
              type="button"
              variant="outline"
              size="sm"
              icon={<Plus className="w-4 h-4 text-[#159B76]" />}
              onClick={handleAddPost}
            >
              Add Another Post
            </AdminButton>
          </div>
        </div>
      )}
    </div>
  );
};
