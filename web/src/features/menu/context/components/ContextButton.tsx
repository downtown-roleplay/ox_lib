import { Button, createStyles, Group, HoverCard, Image, Progress, Stack, Text } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import { ContextMenuProps, Option } from '../../../../typings';
import { fetchNui } from '../../../../utils/fetchNui';
import { isIconUrl } from '../../../../utils/isIconUrl';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import MarkdownComponents from '../../../../config/MarkdownComponents';
import LibIcon from '../../../../components/LibIcon';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: false });
};

const clickContext = (id: string) => {
  fetchNui('clickContext', id);
};

const useStyles = createStyles((theme, params: { disabled?: boolean; readOnly?: boolean }) => ({
  inner: {
    justifyContent: 'flex-start',
  },
  label: {
    width: '100%',
    color: params.disabled ? 'var(--dt-text-dim)' : 'var(--dt-text)',
    whiteSpace: 'pre-wrap',
  },
  button: {
    height: 'fit-content',
    width: '100%',
    padding: '15px 18px',
    borderRadius: 0,
    border: 'none',
    borderBottom: '1px solid var(--dt-hairline)',
    borderLeft: '2px solid transparent',
    backgroundColor: 'transparent',
    backgroundImage: 'none',
    transition: 'background-color 120ms, border-color 120ms',
    '&:hover': {
      backgroundColor: params.readOnly ? 'transparent' : 'var(--dt-select)',
      borderLeftColor: params.readOnly ? 'transparent' : 'var(--dt-accent-light)',
      cursor: params.readOnly ? 'unset' : 'pointer',
    },
    '&:active': {
      transform: 'none',
      backgroundColor: params.readOnly ? 'transparent' : 'var(--dt-select-strong)',
    },
    '&[data-disabled]': {
      backgroundColor: 'transparent',
      opacity: 0.55,
    },
  },
  iconImage: {
    maxWidth: '22px',
  },
  title: {
    fontFamily: 'var(--dt-font-display)',
    fontSize: 18,
    letterSpacing: '0.05em',
    lineHeight: 1.3,
    overflowWrap: 'break-word',
    textShadow: 'var(--dt-shadow-text)',
  },
  description: {
    color: params.disabled ? 'var(--dt-text-dim)' : 'var(--dt-text-muted)',
    fontFamily: 'var(--dt-font-body)',
    fontWeight: 300,
    fontSize: 15,
    lineHeight: 1.45,
  },
  dropdown: {
    padding: '10px 12px',
    color: 'var(--dt-text)',
    fontFamily: 'var(--dt-font-body)',
    fontSize: 15,
    maxWidth: 300,
    width: 'fit-content',
    backgroundColor: 'var(--dt-panel-solid)',
    border: '1px solid var(--dt-hairline-strong)',
    borderRadius: 2,
    boxShadow: 'var(--dt-shadow-panel)',
  },
  buttonStack: {
    gap: 3,
    flex: '1',
  },
  buttonGroup: {
    gap: 10,
    flexWrap: 'nowrap',
  },
  buttonIconContainer: {
    width: 26,
    height: 26,
    fontSize: 20,
    justifyContent: 'center',
    alignItems: 'center',
    color: params.disabled ? 'var(--dt-text-dim)' : 'var(--dt-accent-light)',
  },
  buttonArrowContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    width: 20,
    height: 20,
    fontSize: 15,
    color: 'var(--dt-text-dim)',
  },
  progress: {
    backgroundColor: 'rgba(0, 0, 0, 0.55)',
    border: '1px solid var(--dt-hairline)',
    borderRadius: 0,
    marginTop: 4,
  },
  progressBar: {
    backgroundColor: 'var(--dt-accent-light)',
  },
}));

const ContextButton: React.FC<{
  option: [string, Option];
}> = ({ option }) => {
  const button = option[1];
  const buttonKey = option[0];
  const { classes } = useStyles({ disabled: button.disabled, readOnly: button.readOnly });

  return (
    <>
      <HoverCard
        position="right-start"
        disabled={button.disabled || !(button.metadata || button.image)}
        openDelay={200}
      >
        <HoverCard.Target>
          <Button
            classNames={{ inner: classes.inner, label: classes.label, root: classes.button }}
            onClick={() =>
              !button.disabled && !button.readOnly
                ? button.menu
                  ? openMenu(button.menu)
                  : clickContext(buttonKey)
                : null
            }
            variant="default"
            disabled={button.disabled}
          >
            <Group position="apart" w="100%" noWrap>
              <Stack className={classes.buttonStack}>
                {(button.title || Number.isNaN(+buttonKey)) && (
                  <Group className={classes.buttonGroup}>
                    {button?.icon && (
                      <Stack className={classes.buttonIconContainer}>
                        {typeof button.icon === 'string' && isIconUrl(button.icon) ? (
                          <img src={button.icon} className={classes.iconImage} alt="Missing img" />
                        ) : (
                          <LibIcon
                            icon={button.icon as IconProp}
                            fixedWidth
                            style={{ color: button.iconColor }}
                            animation={button.iconAnimation}
                          />
                        )}
                      </Stack>
                    )}
                    <Text className={classes.title}>
                      <ReactMarkdown components={MarkdownComponents}>{button.title || buttonKey}</ReactMarkdown>
                    </Text>
                  </Group>
                )}
                {button.description && (
                  <Text className={classes.description}>
                    <ReactMarkdown components={MarkdownComponents}>{button.description}</ReactMarkdown>
                  </Text>
                )}
                {button.progress !== undefined && (
                  <Progress
                    value={button.progress}
                    size="sm"
                    color={button.colorScheme}
                    classNames={
                      button.colorScheme
                        ? { root: classes.progress }
                        : { root: classes.progress, bar: classes.progressBar }
                    }
                  />
                )}
              </Stack>
              {(button.menu || button.arrow) && button.arrow !== false && (
                <Stack className={classes.buttonArrowContainer}>
                  <LibIcon icon="chevron-right" fixedWidth />
                </Stack>
              )}
            </Group>
          </Button>
        </HoverCard.Target>
        <HoverCard.Dropdown className={classes.dropdown}>
          {button.image && <Image src={button.image} />}
          {Array.isArray(button.metadata) ? (
            button.metadata.map(
              (
                metadata: string | { label: string; value?: any; progress?: number; colorScheme?: string },
                index: number
              ) => (
                <>
                  <Text key={`context-metadata-${index}`}>
                    {typeof metadata === 'string' ? `${metadata}` : `${metadata.label}: ${metadata?.value ?? ''}`}
                  </Text>

                  {typeof metadata === 'object' && metadata.progress !== undefined && (
                    <Progress
                      value={metadata.progress}
                      size="sm"
                      color={metadata.colorScheme || button.colorScheme}
                      classNames={
                        metadata.colorScheme || button.colorScheme
                          ? { root: classes.progress }
                          : { root: classes.progress, bar: classes.progressBar }
                      }
                    />
                  )}
                </>
              )
            )
          ) : (
            <>
              {typeof button.metadata === 'object' &&
                Object.entries(button.metadata).map((metadata: { [key: string]: any }, index) => (
                  <Text key={`context-metadata-${index}`}>
                    {metadata[0]}: {metadata[1]}
                  </Text>
                ))}
            </>
          )}
        </HoverCard.Dropdown>
      </HoverCard>
    </>
  );
};

export default ContextButton;
