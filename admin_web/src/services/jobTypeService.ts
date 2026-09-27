import {
  collection,
  doc,
  getDocs,
  setDoc,
  deleteDoc,
  query,
  orderBy,
} from 'firebase/firestore';
import { db, auth } from '../firebase/config';
import { JobTypeItem } from '../types';

const COLLECTION_NAME = 'job_types';

export const defaultJobTypes: JobTypeItem[] = [
  {
    id: 'government',
    name: 'Government Employment',
    shortName: 'Govt',
    slug: 'government',
    description: 'Permanent central or state government post',
    order: 1,
    isActive: true,
    colorToken: 'emerald',
  },
  {
    id: 'private',
    name: 'Private Sector',
    shortName: 'Private',
    slug: 'private',
    description: 'Corporate, local enterprise, or island private job',
    order: 2,
    isActive: true,
    colorToken: 'blue',
  },
  {
    id: 'contractual',
    name: 'Contractual Employment',
    shortName: 'Contractual',
    slug: 'contractual',
    description: 'Fixed term or contract basis recruitment',
    order: 3,
    isActive: true,
    colorToken: 'amber',
  },
  {
    id: 'temporary',
    name: 'Temporary Post',
    shortName: 'Temporary',
    slug: 'temporary',
    description: 'Short term urgent requirement',
    order: 4,
    isActive: true,
    colorToken: 'purple',
  },
  {
    id: 'apprentice',
    name: 'Apprenticeship / Training',
    shortName: 'Apprentice',
    slug: 'apprentice',
    description: 'Trade apprentice or technical training vacancy',
    order: 5,
    isActive: true,
    colorToken: 'cyan',
  },
  {
    id: 'internship',
    name: 'Internship',
    shortName: 'Internship',
    slug: 'internship',
    description: 'Paid or stipend-backed internship',
    order: 6,
    isActive: true,
    colorToken: 'indigo',
  },
  {
    id: 'walk_in',
    name: 'Walk-in Interview',
    shortName: 'Walk-in',
    slug: 'walk_in',
    description: 'Direct walk-in recruitment without written prelims',
    order: 7,
    isActive: true,
    colorToken: 'orange',
  },
];

let memoryJobTypes: JobTypeItem[] = [...defaultJobTypes];

export async function fetchJobTypes(): Promise<JobTypeItem[]> {
  try {
    const q = query(collection(db, COLLECTION_NAME), orderBy('order', 'asc'));
    const snap = await getDocs(q);
    const list: JobTypeItem[] = [];
    snap.forEach((d) => list.push({ id: d.id, ...d.data() } as JobTypeItem));

    if (list.length > 0) {
      memoryJobTypes = list;
      return list;
    }

    // Auto-seed to Firestore if empty and admin is authenticated
    if (auth.currentUser) {
      console.log('Auto-seeding default job types to Firestore...');
      for (const jt of defaultJobTypes) {
        await setDoc(doc(db, COLLECTION_NAME, jt.id), jt, { merge: true });
      }
    }
    return defaultJobTypes;
  } catch (err) {
    console.error('Error loading job_types from Firestore:', err);
    return memoryJobTypes;
  }
}

export async function saveJobType(jobType: Partial<JobTypeItem>): Promise<void> {
  const id = jobType.id || jobType.slug || `jt-${Date.now()}`;
  const payload: JobTypeItem = {
    id,
    name: jobType.name || '',
    shortName: jobType.shortName || jobType.name || '',
    slug: jobType.slug || id.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
    description: jobType.description || '',
    icon: jobType.icon || 'Briefcase',
    order: jobType.order ?? memoryJobTypes.length + 1,
    isActive: jobType.isActive ?? true,
    colorToken: jobType.colorToken || 'blue',
  };

  const idx = memoryJobTypes.findIndex((j) => j.id === id);
  if (idx >= 0) {
    memoryJobTypes[idx] = payload;
  } else {
    memoryJobTypes.push(payload);
  }

  try {
    await setDoc(doc(db, COLLECTION_NAME, id), payload, { merge: true });
  } catch (err) {
    console.error('Error saving job type to Firestore:', err);
  }
}

export async function deleteJobType(id: string): Promise<void> {
  memoryJobTypes = memoryJobTypes.filter((j) => j.id !== id);
  try {
    await deleteDoc(doc(db, COLLECTION_NAME, id));
  } catch (err) {
    console.error('Error deleting job type from Firestore:', err);
  }
}

export async function reorderJobTypes(items: JobTypeItem[]): Promise<void> {
  memoryJobTypes = items.map((item, idx) => ({ ...item, order: idx + 1 }));
  try {
    for (const item of memoryJobTypes) {
      await setDoc(doc(db, COLLECTION_NAME, item.id), { order: item.order }, { merge: true });
    }
  } catch (err) {
    console.error('Error reordering job types in Firestore:', err);
  }
}
