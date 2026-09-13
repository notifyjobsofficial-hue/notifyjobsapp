import {
  collection,
  doc,
  getDocs,
  setDoc,
  deleteDoc,
  query,
  orderBy,
} from 'firebase/firestore';
import { db, isFirebaseConfigured } from '../firebase/config';
import { Category } from '../types';

const COLLECTION_NAME = 'categories';

let memoryCategories: Category[] = [
  { id: 'latest-jobs', name: 'Latest Jobs', slug: 'latest-jobs', icon: 'Briefcase', color: '#159B76', order: 1, isActive: true },
  { id: 'andaman-nicobar', name: 'Andaman & Nicobar Jobs', slug: 'andaman-nicobar', icon: 'MapPin', color: '#0D9488', order: 2, isActive: true },
  { id: 'ssc', name: 'SSC Jobs', slug: 'ssc', icon: 'Landmark', color: '#2563EB', order: 3, isActive: true },
  { id: 'railway', name: 'Railway Jobs', slug: 'railway', icon: 'Train', color: '#DC2626', order: 4, isActive: true },
  { id: 'banking', name: 'Banking Jobs', slug: 'banking', icon: 'Banknote', color: '#059669', order: 5, isActive: true },
  { id: 'police-defence', name: 'Police / Defence', slug: 'police-defence', icon: 'Shield', color: '#D97706', order: 6, isActive: true },
  { id: 'admit-cards', name: 'Admit Cards', slug: 'admit-cards', icon: 'FileText', color: '#7C3AED', order: 7, isActive: true },
  { id: 'results', name: 'Results', slug: 'results', icon: 'Award', color: '#EA580C', order: 8, isActive: true },
  { id: 'answer-keys', name: 'Answer Keys', slug: 'answer-keys', icon: 'CheckSquare', color: '#0284C7', order: 9, isActive: true },
  { id: 'syllabus', name: 'Syllabus', slug: 'syllabus', icon: 'BookOpen', color: '#475569', order: 10, isActive: true },
  { id: 'articles', name: 'Latest Articles', slug: 'articles', icon: 'Newspaper', color: '#64748B', order: 11, isActive: true },
];

export async function fetchCategories(): Promise<Category[]> {
  try {
    const q = query(collection(db, COLLECTION_NAME), orderBy('order', 'asc'));
    const snap = await getDocs(q);
    const list: Category[] = [];
    snap.forEach((d) => list.push({ id: d.id, ...d.data() } as Category));
    return list.length > 0 ? list : memoryCategories;
  } catch (err) {
    console.error('Error loading categories from Firestore:', err);
    return memoryCategories;
  }
}

export async function saveCategory(category: Partial<Category>): Promise<void> {
  const id = category.id || category.slug || `cat-${Date.now()}`;
  const payload: Category = {
    id,
    name: category.name || '',
    slug: category.slug || id,
    icon: category.icon || 'Briefcase',
    color: category.color || '#159B76',
    order: category.order || 99,
    isActive: category.isActive ?? true,
  };

  try {
    await setDoc(doc(db, COLLECTION_NAME, id), payload, { merge: true });
    const idx = memoryCategories.findIndex((c) => c.id === id);
    if (idx >= 0) memoryCategories[idx] = payload;
    else memoryCategories.push(payload);
  } catch (err) {
    console.error('Error saving category to Firestore:', err);
    const idx = memoryCategories.findIndex((c) => c.id === id);
    if (idx >= 0) memoryCategories[idx] = payload;
    else memoryCategories.push(payload);
  }
}

export async function deleteCategory(id: string): Promise<void> {
  try {
    await deleteDoc(doc(db, COLLECTION_NAME, id));
    memoryCategories = memoryCategories.filter((c) => c.id !== id);
  } catch (err) {
    console.error('Error deleting category from Firestore:', err);
  }
}
