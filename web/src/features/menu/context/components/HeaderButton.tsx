import { createStyles, UnstyledButton } from '@mantine/core';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import LibIcon from '../../../../components/LibIcon';

interface Props {
  icon: IconProp;
  canClose?: boolean;
  hidden?: boolean;
  iconSize: number;
  handleClick: () => void;
}

const useStyles = createStyles((theme, params: { canClose?: boolean; hidden?: boolean }) => ({
  button: {
    width: 30,
    height: 30,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 2,
    border: '1px solid transparent',
    color: params.canClose === false ? 'var(--dt-text-dim)' : 'var(--dt-accent-light)',
    visibility: params.hidden ? 'hidden' : 'visible',
    transition: 'color 120ms, background-color 120ms, border-color 120ms',
    '&:hover': {
      backgroundColor: params.canClose === false ? 'transparent' : 'var(--dt-select)',
      borderColor: params.canClose === false ? 'transparent' : 'var(--dt-rule)',
      color: params.canClose === false ? 'var(--dt-text-dim)' : 'var(--dt-accent-light)',
      cursor: params.canClose === false ? 'not-allowed' : 'pointer',
    },
  },
}));

const HeaderButton: React.FC<Props> = ({ icon, canClose, hidden, iconSize, handleClick }) => {
  const { classes } = useStyles({ canClose, hidden });

  return (
    <UnstyledButton className={classes.button} disabled={canClose === false || hidden} onClick={handleClick}>
      <LibIcon icon={icon} fontSize={iconSize} fixedWidth />
    </UnstyledButton>
  );
};

export default HeaderButton;
