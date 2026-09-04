import { MantineThemeOverride } from '@mantine/core';

// Campos de formulário no mesmo idioma visual dos menus:
// fundo quase preto, filete discreto, foco em vermelho.
const fieldStyles = {
  input: {
    backgroundColor: 'rgba(0, 0, 0, 0.45)',
    borderColor: 'var(--dt-hairline-strong)',
    borderRadius: 2,
    color: 'var(--dt-text)',
    fontFamily: 'var(--dt-font-body)',
    fontSize: 15,
    '&::placeholder': { color: 'var(--dt-text-dim)' },
    '&:focus, &:focus-within': { borderColor: 'var(--dt-accent-light)' },
  },
  icon: { color: 'var(--dt-accent-light)' },
  rightSection: { color: 'var(--dt-text-muted)' },
};

const wrapperStyles = {
  label: {
    color: 'var(--dt-text-muted)',
    fontFamily: 'var(--dt-font-body)',
    fontWeight: 300,
    fontSize: 13,
    textTransform: 'uppercase' as const,
    letterSpacing: '0.16em',
    marginBottom: 6,
  },
  description: {
    color: 'var(--dt-text-dim)',
    fontFamily: 'var(--dt-font-body)',
    fontSize: 14,
  },
  required: { color: 'var(--dt-accent-light)' },
  error: { color: 'var(--dt-accent-light)', fontFamily: 'var(--dt-font-body)' },
};

export const theme: MantineThemeOverride = {
  colorScheme: 'dark',
  // O anel de foco azul do Mantine denunciava a origem web da UI;
  // o realce de foco agora é responsabilidade de cada componente.
  focusRing: 'never',
  fontFamily: 'Roboto',
  shadows: { sm: '1px 1px 3px rgba(0, 0, 0, 0.5)' },
  components: {
    Button: {
      styles: {
        root: {
          border: 'none',
        },
      },
    },
    Input: { styles: fieldStyles },
    InputWrapper: { styles: wrapperStyles },
    Select: {
      styles: {
        ...fieldStyles,
        dropdown: {
          backgroundColor: 'var(--dt-panel-solid)',
          border: '1px solid var(--dt-hairline-strong)',
          borderRadius: 2,
        },
        item: {
          fontFamily: 'var(--dt-font-body)',
          color: 'var(--dt-text)',
          borderRadius: 1,
          '&[data-selected]': {
            backgroundColor: 'var(--dt-select)',
            color: 'var(--dt-text)',
            '&:hover': { backgroundColor: 'var(--dt-select-strong)' },
          },
          '&[data-hovered]': { backgroundColor: 'var(--dt-select)' },
        },
      },
    },
    MultiSelect: {
      styles: {
        ...fieldStyles,
        dropdown: {
          backgroundColor: 'var(--dt-panel-solid)',
          border: '1px solid var(--dt-hairline-strong)',
          borderRadius: 2,
        },
        item: {
          fontFamily: 'var(--dt-font-body)',
          color: 'var(--dt-text)',
          '&[data-selected]': { backgroundColor: 'var(--dt-select)', color: 'var(--dt-text)' },
          '&[data-hovered]': { backgroundColor: 'var(--dt-select)' },
        },
        value: {
          backgroundColor: 'var(--dt-select)',
          color: 'var(--dt-text)',
          borderRadius: 1,
        },
      },
    },
    Checkbox: {
      styles: {
        input: {
          backgroundColor: 'rgba(0, 0, 0, 0.45)',
          borderColor: 'var(--dt-rule)',
          borderRadius: 1,
          '&:checked': { backgroundColor: 'var(--dt-accent)', borderColor: 'var(--dt-accent-light)' },
        },
        inner: { '> svg > path': { fill: 'var(--dt-text)' } },
        label: { color: 'var(--dt-text)', fontFamily: 'var(--dt-font-body)', fontSize: 15 },
      },
    },
    Slider: {
      styles: {
        track: { '&::before': { backgroundColor: 'rgba(0, 0, 0, 0.55)' } },
        bar: { backgroundColor: 'var(--dt-accent)' },
        thumb: {
          backgroundColor: 'var(--dt-panel-solid)',
          borderColor: 'var(--dt-accent-light)',
        },
        markFilled: { borderColor: 'var(--dt-accent-light)' },
        markLabel: { color: 'var(--dt-text-dim)', fontFamily: 'var(--dt-font-body)', fontSize: 13 },
        label: {
          backgroundColor: 'var(--dt-panel-solid)',
          border: '1px solid var(--dt-hairline-strong)',
          color: 'var(--dt-text)',
          fontFamily: 'var(--dt-font-body)',
        },
      },
    },
    Calendar: {
      styles: {
        day: {
          fontFamily: 'var(--dt-font-body)',
          borderRadius: 1,
          '&[data-selected]': { backgroundColor: 'var(--dt-accent)', color: 'var(--dt-text)' },
          '&:hover': { backgroundColor: 'var(--dt-select)' },
        },
      },
    },
  },
};
