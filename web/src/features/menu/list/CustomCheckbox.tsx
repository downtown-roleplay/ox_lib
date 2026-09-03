import { Checkbox, createStyles } from '@mantine/core';

const useStyles = createStyles(() => ({
  root: {
    display: 'flex',
    alignItems: 'center',
  },
  input: {
    width: 20,
    height: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.55)',
    borderColor: 'var(--dt-rule)',
    borderRadius: 1,
    '&:checked': {
      backgroundColor: 'var(--dt-accent)',
      borderColor: 'var(--dt-accent-light)',
    },
  },
  inner: {
    width: 20,
    height: 20,
    '> svg > path': {
      fill: 'var(--dt-text)',
    },
  },
}));

const CustomCheckbox: React.FC<{ checked: boolean }> = ({ checked }) => {
  const { classes } = useStyles();
  return (
    <Checkbox
      checked={checked}
      size="md"
      classNames={{ root: classes.root, input: classes.input, inner: classes.inner }}
    />
  );
};

export default CustomCheckbox;
