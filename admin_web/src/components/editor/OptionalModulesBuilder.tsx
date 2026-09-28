import React from 'react';
import {
  Plus,
  Trash2,
  Shield,
  Activity,
  Award,
  Stethoscope,
  Building,
  FileText,
  AlertCircle,
  Clock,
  HelpCircle,
} from 'lucide-react';
import {
  AgeLimitItem,
  PhysicalStandardItem,
  PETEventItem,
  TradeTestItem,
  MedicalStandardItem,
  DeputationConditions,
  OtherConditionItem,
} from '../../types';
import { AdminInput } from '../common/AdminInput';
import { AdminButton } from '../common/AdminButton';

export type OptionalModuleType =
  | 'age_relaxation'
  | 'physical_standards'
  | 'pet_pst'
  | 'trade_test'
  | 'medical_standards'
  | 'deputation_conditions'
  | 'service_requirements'
  | 'reservation_notes'
  | 'probation_training_bond'
  | 'other_conditions';

export interface OptionalModuleOption {
  type: OptionalModuleType;
  label: string;
  description: string;
  icon: React.ComponentType<{ className?: string }>;
}

export const AVAILABLE_OPTIONAL_MODULES: OptionalModuleOption[] = [
  {
    type: 'age_relaxation',
    label: 'Age Relaxation',
    description: 'Category-wise upper age relaxation rules (SC, ST, OBC, ESM, etc.)',
    icon: Shield,
  },
  {
    type: 'physical_standards',
    label: 'Physical Standards (PST)',
    description: 'Height, chest, and weight requirements across categories and gender',
    icon: Activity,
  },
  {
    type: 'pet_pst',
    label: 'Physical Efficiency Test (PET)',
    description: 'Running, jump, race timings, and physical test events',
    icon: Award,
  },
  {
    type: 'trade_test',
    label: 'Trade / Skill Test',
    description: 'Practical or technical trade skills assessment specifications',
    icon: Award,
  },
  {
    type: 'medical_standards',
    label: 'Medical Standards (DME / RME)',
    description: 'Detailed Medical Examination & Review Medical Examination criteria',
    icon: Stethoscope,
  },
  {
    type: 'deputation_conditions',
    label: 'Deputation Conditions & Tenure',
    description: 'Parent department eligibility, tenure duration, and forwarding rules',
    icon: Building,
  },
  {
    type: 'service_requirements',
    label: 'Service & Experience Details',
    description: 'Prior service conditions, experience certificates, or cadre requirements',
    icon: FileText,
  },
  {
    type: 'reservation_notes',
    label: 'Reservation Notes & Policies',
    description: 'Special reservation clauses for local residents, women, or horizontal quotas',
    icon: AlertCircle,
  },
  {
    type: 'probation_training_bond',
    label: 'Probation, Training & Service Bond',
    description: 'Probation duration, mandatory training, and financial service agreement',
    icon: Clock,
  },
  {
    type: 'other_conditions',
    label: 'Other Recruitment Conditions',
    description: 'Custom structured terms, disqualifications, or administrative clauses',
    icon: HelpCircle,
  },
];

interface OptionalModulesBuilderProps {
  enabledModules: OptionalModuleType[];
  onToggleModule: (type: OptionalModuleType, enable: boolean) => void;

  // Module state
  ageRelaxations?: AgeLimitItem[];
  onAgeRelaxationsChange: (items: AgeLimitItem[]) => void;

  physicalStandards?: PhysicalStandardItem[];
  onPhysicalStandardsChange: (items: PhysicalStandardItem[]) => void;

  petEvents?: PETEventItem[];
  onPETEventsChange: (items: PETEventItem[]) => void;

  tradeTests?: TradeTestItem[];
  onTradeTestsChange: (items: TradeTestItem[]) => void;

  medicalStandards?: MedicalStandardItem[];
  onMedicalStandardsChange: (items: MedicalStandardItem[]) => void;

  deputationConditions?: DeputationConditions;
  onDeputationConditionsChange: (conds: DeputationConditions) => void;

  serviceRequirements?: string;
  onServiceRequirementsChange: (val: string) => void;

  reservationNotes?: string[];
  onReservationNotesChange: (notes: string[]) => void;

  probationPeriod?: string;
  onProbationPeriodChange: (val: string) => void;
  trainingPeriod?: string;
  onTrainingPeriodChange: (val: string) => void;
  serviceBond?: string;
  onServiceBondChange: (val: string) => void;

  otherConditions?: OtherConditionItem[];
  onOtherConditionsChange: (items: OtherConditionItem[]) => void;
}

export const OptionalModulesBuilder: React.FC<OptionalModulesBuilderProps> = ({
  enabledModules,
  onToggleModule,
  ageRelaxations = [],
  onAgeRelaxationsChange,
  physicalStandards = [],
  onPhysicalStandardsChange,
  petEvents = [],
  onPETEventsChange,
  tradeTests = [],
  onTradeTestsChange,
  medicalStandards = [],
  onMedicalStandardsChange,
  deputationConditions = {},
  onDeputationConditionsChange,
  serviceRequirements = '',
  onServiceRequirementsChange,
  reservationNotes = [],
  onReservationNotesChange,
  probationPeriod = '',
  onProbationPeriodChange,
  trainingPeriod = '',
  onTrainingPeriodChange,
  serviceBond = '',
  onServiceBondChange,
  otherConditions = [],
  onOtherConditionsChange,
}) => {
  const [selectedToAdd, setSelectedToAdd] = React.useState<OptionalModuleType | ''>('');

  const unusedModules = AVAILABLE_OPTIONAL_MODULES.filter(
    (m) => !enabledModules.includes(m.type)
  );

  const handleAddModule = (type: OptionalModuleType) => {
    onToggleModule(type, true);
    setSelectedToAdd('');
  };

  return (
    <div className="space-y-6">
      {/* 1. Add Optional Section Bar */}
      <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl flex flex-wrap items-center justify-between gap-3">
        <div>
          <h4 className="text-sm font-semibold text-slate-900">
            Optional Recruitment Specifications
          </h4>
          <p className="text-xs text-slate-500">
            Enable only modules required for this notification (e.g. Physical tests for Police/Defence, Trade test for technical posts)
          </p>
        </div>

        <div className="flex items-center gap-2">
          {unusedModules.length > 0 && (
            <select
              value={selectedToAdd}
              onChange={(e) => {
                if (e.target.value) {
                  handleAddModule(e.target.value as OptionalModuleType);
                }
              }}
              className="text-xs px-3 py-2 bg-white border border-slate-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-[#FF5A00] font-medium text-slate-700"
            >
              <option value="">+ Add Optional Section...</option>
              {unusedModules.map((m) => (
                <option key={m.type} value={m.type}>
                  + {m.label}
                </option>
              ))}
            </select>
          )}
        </div>
      </div>

      {/* 2. Render Enabled Modules */}
      {enabledModules.map((type) => {
        const option = AVAILABLE_OPTIONAL_MODULES.find((m) => m.type === type);
        if (!option) return null;
        const Icon = option.icon;

        return (
          <div
            key={type}
            className="border border-slate-200 bg-white rounded-xl shadow-sm overflow-hidden"
          >
            {/* Header */}
            <div className="px-5 py-3.5 bg-slate-50/80 border-b border-slate-200 flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="p-1.5 bg-[#FFF0EB] text-[#FF5A00] rounded-lg">
                  <Icon className="w-4 h-4" />
                </div>
                <div>
                  <h5 className="text-sm font-bold text-slate-800">{option.label}</h5>
                  <p className="text-xs text-slate-500">{option.description}</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => onToggleModule(type, false)}
                className="text-xs text-red-600 hover:text-red-700 flex items-center gap-1 font-semibold hover:bg-red-50 px-2.5 py-1 rounded-lg transition-colors"
                title="Remove this section"
              >
                <Trash2 className="w-3.5 h-3.5" />
                Remove Section
              </button>
            </div>

            {/* Content */}
            <div className="p-5">
              {/* MODULE: AGE RELAXATION */}
              {type === 'age_relaxation' && (
                <div className="space-y-4">
                  <div className="space-y-2">
                    {ageRelaxations.map((rel, idx) => (
                      <div
                        key={rel.id || idx}
                        className="grid grid-cols-1 sm:grid-cols-4 gap-2.5 items-end p-2.5 bg-slate-50 rounded-lg border border-slate-100"
                      >
                        <AdminInput
                          label="Category"
                          placeholder="e.g. OBC / SC / ST / ESM"
                          value={rel.category}
                          onChange={(e) => {
                            const updated = [...ageRelaxations];
                            updated[idx] = { ...updated[idx], category: e.target.value };
                            onAgeRelaxationsChange(updated);
                          }}
                        />
                        <AdminInput
                          label="Relaxation Years"
                          placeholder="e.g. 3 years / 5 years"
                          value={rel.relaxationYears}
                          onChange={(e) => {
                            const updated = [...ageRelaxations];
                            updated[idx] = { ...updated[idx], relaxationYears: e.target.value };
                            onAgeRelaxationsChange(updated);
                          }}
                        />
                        <AdminInput
                          label="Max Age Override (Optional)"
                          placeholder="e.g. 40 years"
                          value={rel.maximumAgeOverride || ''}
                          onChange={(e) => {
                            const updated = [...ageRelaxations];
                            updated[idx] = { ...updated[idx], maximumAgeOverride: e.target.value };
                            onAgeRelaxationsChange(updated);
                          }}
                        />
                        <div className="flex items-center gap-1">
                          <div className="flex-1">
                            <AdminInput
                              label="Notes"
                              placeholder="e.g. As per GoI rules"
                              value={rel.notes || ''}
                              onChange={(e) => {
                                const updated = [...ageRelaxations];
                                updated[idx] = { ...updated[idx], notes: e.target.value };
                                onAgeRelaxationsChange(updated);
                              }}
                            />
                          </div>
                          <button
                            type="button"
                            onClick={() => {
                              onAgeRelaxationsChange(ageRelaxations.filter((_, i) => i !== idx));
                            }}
                            className="p-2 text-slate-400 hover:text-red-500 rounded-lg"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                  <AdminButton
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      onAgeRelaxationsChange([
                        ...ageRelaxations,
                        {
                          id: `rel-${Date.now()}`,
                          category: '',
                          relaxationYears: '',
                          notes: '',
                        },
                      ]);
                    }}
                  >
                    <Plus className="w-3.5 h-3.5 mr-1" /> Add Age Relaxation Row
                  </AdminButton>
                </div>
              )}

              {/* MODULE: PHYSICAL STANDARDS (PST) */}
              {type === 'physical_standards' && (
                <div className="space-y-4">
                  <div className="space-y-2">
                    {physicalStandards.map((item, idx) => (
                      <div
                        key={item.id || idx}
                        className="grid grid-cols-2 sm:grid-cols-6 gap-2 items-end p-2.5 bg-slate-50 rounded-lg border border-slate-100 text-xs"
                      >
                        <AdminInput
                          label="Category / Region"
                          placeholder="e.g. General / Gorkha / ST"
                          value={item.category}
                          onChange={(e) => {
                            const updated = [...physicalStandards];
                            updated[idx] = { ...updated[idx], category: e.target.value };
                            onPhysicalStandardsChange(updated);
                          }}
                        />
                        <div>
                          <label className="block text-xs font-semibold text-slate-600 mb-1">
                            Gender
                          </label>
                          <select
                            value={item.gender}
                            onChange={(e) => {
                              const updated = [...physicalStandards];
                              updated[idx] = {
                                ...updated[idx],
                                gender: e.target.value as 'male' | 'female' | 'all',
                              };
                              onPhysicalStandardsChange(updated);
                            }}
                            className="w-full text-xs px-2 py-2 bg-white border border-slate-300 rounded-lg"
                          >
                            <option value="male">Male</option>
                            <option value="female">Female</option>
                            <option value="all">All</option>
                          </select>
                        </div>
                        <AdminInput
                          label="Min Height (cm)"
                          placeholder="e.g. 170 cm"
                          value={item.height || ''}
                          onChange={(e) => {
                            const updated = [...physicalStandards];
                            updated[idx] = { ...updated[idx], height: e.target.value };
                            onPhysicalStandardsChange(updated);
                          }}
                        />
                        <AdminInput
                          label="Chest (Normal)"
                          placeholder="e.g. 80 cm"
                          value={item.chest || ''}
                          onChange={(e) => {
                            const updated = [...physicalStandards];
                            updated[idx] = { ...updated[idx], chest: e.target.value };
                            onPhysicalStandardsChange(updated);
                          }}
                        />
                        <AdminInput
                          label="Chest (Expanded)"
                          placeholder="e.g. 85 cm (+5)"
                          value={item.chestExpanded || ''}
                          onChange={(e) => {
                            const updated = [...physicalStandards];
                            updated[idx] = { ...updated[idx], chestExpanded: e.target.value };
                            onPhysicalStandardsChange(updated);
                          }}
                        />
                        <div className="flex items-center gap-1">
                          <div className="flex-1">
                            <AdminInput
                              label="Weight"
                              placeholder="e.g. Proportionate"
                              value={item.weight || ''}
                              onChange={(e) => {
                                const updated = [...physicalStandards];
                                updated[idx] = { ...updated[idx], weight: e.target.value };
                                onPhysicalStandardsChange(updated);
                              }}
                            />
                          </div>
                          <button
                            type="button"
                            onClick={() => {
                              onPhysicalStandardsChange(physicalStandards.filter((_, i) => i !== idx));
                            }}
                            className="p-1.5 text-slate-400 hover:text-red-500 rounded"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                  <AdminButton
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      onPhysicalStandardsChange([
                        ...physicalStandards,
                        {
                          id: `pst-${Date.now()}`,
                          category: 'General / OBC / SC',
                          gender: 'male',
                          height: '',
                          chest: '',
                          chestExpanded: '',
                        },
                      ]);
                    }}
                  >
                    <Plus className="w-3.5 h-3.5 mr-1" /> Add Physical Standard Row
                  </AdminButton>
                </div>
              )}

              {/* MODULE: PET REQUIREMENTS */}
              {type === 'pet_pst' && (
                <div className="space-y-4">
                  <div className="space-y-2">
                    {petEvents.map((event, idx) => (
                      <div
                        key={event.id || idx}
                        className="grid grid-cols-1 sm:grid-cols-4 gap-2.5 items-end p-2.5 bg-slate-50 rounded-lg border border-slate-100"
                      >
                        <AdminInput
                          label="Event Name"
                          placeholder="e.g. 5 Km Run / 1.6 Km Run"
                          value={event.eventName}
                          onChange={(e) => {
                            const updated = [...petEvents];
                            updated[idx] = { ...updated[idx], eventName: e.target.value };
                            onPETEventsChange(updated);
                          }}
                        />
                        <div>
                          <label className="block text-xs font-semibold text-slate-600 mb-1">
                            Gender
                          </label>
                          <select
                            value={event.gender}
                            onChange={(e) => {
                              const updated = [...petEvents];
                              updated[idx] = {
                                ...updated[idx],
                                gender: e.target.value as 'male' | 'female' | 'all',
                              };
                              onPETEventsChange(updated);
                            }}
                            className="w-full text-xs px-2 py-2 bg-white border border-slate-300 rounded-lg"
                          >
                            <option value="male">Male</option>
                            <option value="female">Female</option>
                            <option value="all">All</option>
                          </select>
                        </div>
                        <AdminInput
                          label="Qualifying Time / Distance"
                          placeholder="e.g. 24 Minutes / 800m in 4 mins"
                          value={event.standard}
                          onChange={(e) => {
                            const updated = [...petEvents];
                            updated[idx] = { ...updated[idx], standard: e.target.value };
                            onPETEventsChange(updated);
                          }}
                        />
                        <div className="flex items-center gap-1">
                          <div className="flex-1">
                            <AdminInput
                              label="Notes"
                              placeholder="e.g. Qualifying in nature"
                              value={event.notes || ''}
                              onChange={(e) => {
                                const updated = [...petEvents];
                                updated[idx] = { ...updated[idx], notes: e.target.value };
                                onPETEventsChange(updated);
                              }}
                            />
                          </div>
                          <button
                            type="button"
                            onClick={() => {
                              onPETEventsChange(petEvents.filter((_, i) => i !== idx));
                            }}
                            className="p-1.5 text-slate-400 hover:text-red-500 rounded"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                  <AdminButton
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      onPETEventsChange([
                        ...petEvents,
                        {
                          id: `pet-${Date.now()}`,
                          eventName: 'Race / Run',
                          gender: 'male',
                          standard: '',
                          notes: 'Qualifying in nature',
                        },
                      ]);
                    }}
                  >
                    <Plus className="w-3.5 h-3.5 mr-1" /> Add PET Event
                  </AdminButton>
                </div>
              )}

              {/* MODULE: TRADE TEST / SKILL TEST */}
              {type === 'trade_test' && (
                <div className="space-y-4">
                  <div className="space-y-2">
                    {tradeTests.map((trade, idx) => (
                      <div
                        key={trade.id || idx}
                        className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 items-end p-2.5 bg-slate-50 rounded-lg border border-slate-100"
                      >
                        <AdminInput
                          label="Post / Trade Name"
                          placeholder="e.g. Cook / Electrician / Clerk"
                          value={trade.postOrTrade}
                          onChange={(e) => {
                            const updated = [...tradeTests];
                            updated[idx] = { ...updated[idx], postOrTrade: e.target.value };
                            onTradeTestsChange(updated);
                          }}
                        />
                        <AdminInput
                          label="Test Specifications"
                          placeholder="e.g. Typing speed: 35 WPM / Cooking test"
                          value={trade.criteria}
                          onChange={(e) => {
                            const updated = [...tradeTests];
                            updated[idx] = { ...updated[idx], criteria: e.target.value };
                            onTradeTestsChange(updated);
                          }}
                        />
                        <div className="flex items-center gap-1">
                          <div className="flex-1">
                            <AdminInput
                              label="Qualifying Marks"
                              placeholder="e.g. Qualifying / 33%"
                              value={trade.qualifyingMarks || ''}
                              onChange={(e) => {
                                const updated = [...tradeTests];
                                updated[idx] = { ...updated[idx], qualifyingMarks: e.target.value };
                                onTradeTestsChange(updated);
                              }}
                            />
                          </div>
                          <button
                            type="button"
                            onClick={() => {
                              onTradeTestsChange(tradeTests.filter((_, i) => i !== idx));
                            }}
                            className="p-1.5 text-slate-400 hover:text-red-500 rounded"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                  <AdminButton
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      onTradeTestsChange([
                        ...tradeTests,
                        {
                          id: `trade-${Date.now()}`,
                          postOrTrade: '',
                          testName: 'Trade Skill Test',
                          criteria: '',
                          qualifyingMarks: 'Qualifying',
                        },
                      ]);
                    }}
                  >
                    <Plus className="w-3.5 h-3.5 mr-1" /> Add Trade / Skill Test Row
                  </AdminButton>
                </div>
              )}

              {/* MODULE: MEDICAL STANDARDS */}
              {type === 'medical_standards' && (
                <div className="space-y-4">
                  <div className="space-y-2">
                    {medicalStandards.map((med, idx) => (
                      <div
                        key={med.id || idx}
                        className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 items-end p-2.5 bg-slate-50 rounded-lg border border-slate-100"
                      >
                        <div>
                          <label className="block text-xs font-semibold text-slate-600 mb-1">
                            Stage / Type
                          </label>
                          <select
                            value={med.stage}
                            onChange={(e) => {
                              const updated = [...medicalStandards];
                              updated[idx] = {
                                ...updated[idx],
                                stage: e.target.value as 'DME' | 'RME' | 'General',
                              };
                              onMedicalStandardsChange(updated);
                            }}
                            className="w-full text-xs px-2 py-2 bg-white border border-slate-300 rounded-lg"
                          >
                            <option value="DME">Detailed Medical Exam (DME)</option>
                            <option value="RME">Review Medical Exam (RME)</option>
                            <option value="General">General Medical Standards</option>
                          </select>
                        </div>
                        <AdminInput
                          label="Eyesight / Vision Standard"
                          placeholder="e.g. 6/6, 6/9 without glasses"
                          value={med.eyesightStandard || ''}
                          onChange={(e) => {
                            const updated = [...medicalStandards];
                            updated[idx] = { ...updated[idx], eyesightStandard: e.target.value };
                            onMedicalStandardsChange(updated);
                          }}
                        />
                        <div className="flex items-center gap-1">
                          <div className="flex-1">
                            <AdminInput
                              label="Standards & Guidelines"
                              placeholder="e.g. Free from color blindness, flat foot, knock knee"
                              value={med.criteria}
                              onChange={(e) => {
                                const updated = [...medicalStandards];
                                updated[idx] = { ...updated[idx], criteria: e.target.value };
                                onMedicalStandardsChange(updated);
                              }}
                            />
                          </div>
                          <button
                            type="button"
                            onClick={() => {
                              onMedicalStandardsChange(medicalStandards.filter((_, i) => i !== idx));
                            }}
                            className="p-1.5 text-slate-400 hover:text-red-500 rounded"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                  <AdminButton
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      onMedicalStandardsChange([
                        ...medicalStandards,
                        {
                          id: `med-${Date.now()}`,
                          stage: 'DME',
                          standardName: 'Detailed Medical Examination',
                          criteria: 'Must be in good mental and bodily health.',
                          eyesightStandard: '6/6',
                        },
                      ]);
                    }}
                  >
                    <Plus className="w-3.5 h-3.5 mr-1" /> Add Medical Standard Row
                  </AdminButton>
                </div>
              )}

              {/* MODULE: DEPUTATION CONDITIONS */}
              {type === 'deputation_conditions' && (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <AdminInput
                    label="Parent Department / Cadre"
                    placeholder="e.g. Central / State Government officers"
                    value={deputationConditions.parentDepartment || ''}
                    onChange={(e) =>
                      onDeputationConditionsChange({
                        ...deputationConditions,
                        parentDepartment: e.target.value,
                      })
                    }
                  />
                  <AdminInput
                    label="Minimum Service Required"
                    placeholder="e.g. 5 years regular service in Level-7"
                    value={deputationConditions.minimumServiceYears || ''}
                    onChange={(e) =>
                      onDeputationConditionsChange({
                        ...deputationConditions,
                        minimumServiceYears: e.target.value,
                      })
                    }
                  />
                  <AdminInput
                    label="Deputation Tenure"
                    placeholder="e.g. Ordinarily 3 years, extendable up to 5 years"
                    value={deputationConditions.deputationTenure || ''}
                    onChange={(e) =>
                      onDeputationConditionsChange({
                        ...deputationConditions,
                        deputationTenure: e.target.value,
                      })
                    }
                  />
                  <AdminInput
                    label="Maximum Age Limit for Deputation"
                    placeholder="e.g. Not exceeding 56 years on closing date"
                    value={deputationConditions.maximumAge || ''}
                    onChange={(e) =>
                      onDeputationConditionsChange({
                        ...deputationConditions,
                        maximumAge: e.target.value,
                      })
                    }
                  />
                  <div className="sm:col-span-2">
                    <AdminInput
                      label="Forwarding Authority / Cadre Clearance"
                      placeholder="e.g. Applications must be routed through proper channel with ACRs/APARs for last 5 years"
                      value={deputationConditions.forwardingRules || ''}
                      onChange={(e) =>
                        onDeputationConditionsChange({
                          ...deputationConditions,
                          forwardingRules: e.target.value,
                        })
                      }
                    />
                  </div>
                </div>
              )}

              {/* MODULE: SERVICE & EXPERIENCE */}
              {type === 'service_requirements' && (
                <div>
                  <textarea
                    rows={3}
                    placeholder="Specify detailed service conditions, mandatory experience, or trade certifications required for appointment..."
                    value={serviceRequirements}
                    onChange={(e) => onServiceRequirementsChange(e.target.value)}
                    className="w-full text-xs p-3 bg-white border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#FF5A00]"
                  />
                </div>
              )}

              {/* MODULE: RESERVATION NOTES */}
              {type === 'reservation_notes' && (
                <div className="space-y-3">
                  <div className="space-y-2">
                    {reservationNotes.map((note, idx) => (
                      <div key={idx} className="flex items-center gap-2">
                        <input
                          type="text"
                          value={note}
                          placeholder="e.g. Horizontal reservation of 10% for Ex-Servicemen"
                          onChange={(e) => {
                            const updated = [...reservationNotes];
                            updated[idx] = e.target.value;
                            onReservationNotesChange(updated);
                          }}
                          className="flex-1 text-xs px-3 py-2 bg-white border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#FF5A00]"
                        />
                        <button
                          type="button"
                          onClick={() => {
                            onReservationNotesChange(reservationNotes.filter((_, i) => i !== idx));
                          }}
                          className="p-1.5 text-slate-400 hover:text-red-500 rounded"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                  <AdminButton
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => onReservationNotesChange([...reservationNotes, ''])}
                  >
                    <Plus className="w-3.5 h-3.5 mr-1" /> Add Reservation Note
                  </AdminButton>
                </div>
              )}

              {/* MODULE: PROBATION, TRAINING & BOND */}
              {type === 'probation_training_bond' && (
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                  <AdminInput
                    label="Probation Period"
                    placeholder="e.g. 2 Years"
                    value={probationPeriod}
                    onChange={(e) => onProbationPeriodChange(e.target.value)}
                  />
                  <AdminInput
                    label="Training Period"
                    placeholder="e.g. 6 Months Basic Training"
                    value={trainingPeriod}
                    onChange={(e) => onTrainingPeriodChange(e.target.value)}
                  />
                  <AdminInput
                    label="Service Agreement Bond"
                    placeholder="e.g. ₹2,00,000 for 3 years"
                    value={serviceBond}
                    onChange={(e) => onServiceBondChange(e.target.value)}
                  />
                </div>
              )}

              {/* MODULE: OTHER CONDITIONS */}
              {type === 'other_conditions' && (
                <div className="space-y-3">
                  <div className="space-y-2">
                    {otherConditions.map((cond, idx) => (
                      <div
                        key={cond.id || idx}
                        className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 items-end p-2.5 bg-slate-50 rounded-lg border border-slate-100"
                      >
                        <AdminInput
                          label="Title"
                          placeholder="e.g. Disqualification Clause"
                          value={cond.title}
                          onChange={(e) => {
                            const updated = [...otherConditions];
                            updated[idx] = { ...updated[idx], title: e.target.value };
                            onOtherConditionsChange(updated);
                          }}
                        />
                        <div className="sm:col-span-2 flex items-center gap-1">
                          <div className="flex-1">
                            <AdminInput
                              label="Description"
                              placeholder="e.g. Candidates having more than one spouse living are not eligible."
                              value={cond.description}
                              onChange={(e) => {
                                const updated = [...otherConditions];
                                updated[idx] = { ...updated[idx], description: e.target.value };
                                onOtherConditionsChange(updated);
                              }}
                            />
                          </div>
                          <button
                            type="button"
                            onClick={() => {
                              onOtherConditionsChange(otherConditions.filter((_, i) => i !== idx));
                            }}
                            className="p-1.5 text-slate-400 hover:text-red-500 rounded"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                  <AdminButton
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      onOtherConditionsChange([
                        ...otherConditions,
                        { id: `cond-${Date.now()}`, title: '', description: '' },
                      ]);
                    }}
                  >
                    <Plus className="w-3.5 h-3.5 mr-1" /> Add Condition Row
                  </AdminButton>
                </div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
};
