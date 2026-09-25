/**
 * Categorias de instituições da rede de apoio.
 *
 * Cada categoria representa um tipo de serviço público ou organização
 * que compõe a rede de proteção à mulher.
 */
export const INSTITUTION_CATEGORIES = {
  delegacia_mulher: {
    label: 'Delegacia da Mulher',
    description: 'Delegacia Especializada de Atendimento à Mulher (DEAM)',
    icon: '🛡️',
  },
  delegacia_comum: {
    label: 'Delegacia de Polícia',
    description: 'Delegacia de Polícia Civil',
    icon: '🏛️',
  },
  creas: {
    label: 'CREAS',
    description: 'Centro de Referência Especializado de Assistência Social',
    icon: '💜',
  },
  cras: {
    label: 'CRAS',
    description: 'Centro de Referência de Assistência Social',
    icon: '🤝',
  },
  defensoria: {
    label: 'Defensoria Pública',
    description: 'Defensoria Pública do Estado',
    icon: '⚖️',
  },
  ministerio_publico: {
    label: 'Ministério Público',
    description: 'Promotoria de Justiça',
    icon: '📋',
  },
  hospital: {
    label: 'Hospital / UPA',
    description: 'Unidade de saúde com atendimento a vítimas de violência',
    icon: '🏥',
  },
  casa_abrigo: {
    label: 'Casa-Abrigo',
    description: 'Abrigo sigiloso para mulheres em risco',
    icon: '🏠',
  },
  forum: {
    label: 'Vara / Fórum',
    description: 'Vara de Violência Doméstica e Familiar',
    icon: '🏛️',
  },
  centro_referencia: {
    label: 'Centro de Referência da Mulher',
    description: 'Atendimento psicológico, jurídico e social',
    icon: '💗',
  },
  ong: {
    label: 'ONG',
    description: 'Organização não-governamental de apoio à mulher',
    icon: '🌸',
  },
} as const;

export type InstitutionCategory = keyof typeof INSTITUTION_CATEGORIES;

export interface Institution {
  id: string;
  name: string;
  category: InstitutionCategory;
  subcategory?: string;
  address: string;
  city: string;
  state: string;
  zip_code?: string;
  phone?: string;
  phone2?: string;
  email?: string;
  website?: string;
  opening_hours?: Record<string, string>;
  latitude: number;
  longitude: number;
  services?: string[];
  verified_at?: string;
  is_active: boolean;
  distance_km?: number;
}

export interface NearbyQuery {
  lat: number;
  lng: number;
  radius?: number; // metros, padrão 5000
  category?: string;
  limit?: number;
}

export interface SearchQuery {
  q?: string;
  state?: string;
  city?: string;
  category?: string;
  limit?: number;
}
