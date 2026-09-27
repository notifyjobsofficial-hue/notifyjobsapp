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
import { Category } from '../types';

const COLLECTION_NAME = 'categories';

let memoryCategories: Category[] = [
  { id: 'latest-jobs', name: 'Latest Jobs', shortName: 'Latest', slug: 'latest-jobs', icon: 'Briefcase', color: '#159B76', order: 1, isActive: true, showOnHome: true, destination: '/jobs?category=latest-jobs', contentScope: 'job' },
  { id: 'andaman-nicobar', name: 'Andaman & Nicobar Jobs', shortName: 'A&N Jobs', slug: 'andaman-nicobar', icon: 'MapPin', color: '#0D9488', order: 2, isActive: true, showOnHome: true, destination: '/jobs?category=andaman-nicobar', contentScope: 'job' },
  { id: 'ssc', name: 'SSC Jobs', shortName: 'SSC', slug: 'ssc', icon: 'Landmark', color: '#2563EB', order: 3, isActive: true, showOnHome: true, destination: '/jobs?category=ssc', contentScope: 'job' },
  { id: 'railway', name: 'Railway Jobs', shortName: 'Railway', slug: 'railway', icon: 'Train', color: '#DC2626', order: 4, isActive: true, showOnHome: true, destination: '/jobs?category=railway', contentScope: 'job' },
  { id: 'banking', name: 'Banking Jobs', shortName: 'Banking', slug: 'banking', icon: 'Banknote', color: '#059669', order: 5, isActive: true, showOnHome: true, destination: '/jobs?category=banking', contentScope: 'job' },
  { id: 'police-defence', name: 'Police / Defence', shortName: 'Defence', slug: 'police-defence', icon: 'Shield', color: '#D97706', order: 6, isActive: true, showOnHome: true, destination: '/jobs?category=police-defence', contentScope: 'job' },
  { id: 'admit-cards', name: 'Admit Cards', shortName: 'Admit Card', slug: 'admit-cards', icon: 'FileText', color: '#7C3AED', order: 7, isActive: true, showOnHome: true, destination: '/updates?tab=admit_cards', contentScope: 'update' },
  { id: 'results', name: 'Results', shortName: 'Result', slug: 'results', icon: 'Award', color: '#EA580C', order: 8, isActive: true, showOnHome: true, destination: '/updates?tab=results', contentScope: 'update' },
  { id: 'answer-keys', name: 'Answer Keys', shortName: 'Ans Key', slug: 'answer-keys', icon: 'CheckSquare', color: '#0284C7', order: 9, isActive: true, showOnHome: true, destination: '/updates?tab=answer_keys', contentScope: 'update' },
  { id: 'syllabus', name: 'Syllabus', shortName: 'Syllabus', slug: 'syllabus', icon: 'BookOpen', color: '#475569', order: 10, isActive: true, showOnHome: true, destination: '/updates?tab=syllabus', contentScope: 'update' },
  { id: 'articles', name: 'Latest Articles', shortName: 'Articles', slug: 'articles', icon: 'Newspaper', color: '#64748B', order: 11, isActive: true, showOnHome: true, destination: '/more', contentScope: 'article' },
];

export async function fetchCategories(): Promise<Category[]> {
  try {
    const q = query(collection(db, COLLECTION_NAME), orderBy('order', 'asc'));
    const snap = await getDocs(q);
    const list: Category[] = [];
    snap.forEach((d) => list.push({ id: d.id, ...d.data() } as Category));
    
    if (list.length > 0) {
      memoryCategories = list;
      return list;
    }

    // Auto-seed to Firestore if empty and admin is authenticated
    if (auth.currentUser) {
      console.log('Auto-seeding default categories to Firestore...');
      for (const cat of memoryCategories) {
        await setDoc(doc(db, COLLECTION_NAME, cat.id), cat, { merge: true });
      }
    }
    return memoryCategories;
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
    shortName: category.shortName || category.name || '',
    slug: category.slug || id,
    icon: category.icon || 'Briefcase',
    color: category.color || '#159B76',
    order: Number(category.order) || 99,
    isActive: category.isActive ?? true,
    showOnHome: category.showOnHome ?? true,
    destination: category.destination || '',
    contentScope: category.contentScope || 'job',
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
    throw err;
  }
}

export async function deleteCategory(id: string): Promise<void> {
  try {
    await deleteDoc(doc(db, COLLECTION_NAME, id));
    memoryCategories = memoryCategories.filter((c) => c.id !== id);
  } catch (err) {
    console.error('Error deleting category from Firestore:', err);
    throw err;
  }
}
