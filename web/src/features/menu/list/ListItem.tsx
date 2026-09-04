import { Box, createStyles, Group, Progress, Stack, Text } from '@mantine/core';
import React, { forwardRef } from 'react';
import CustomCheckbox from './CustomCheckbox';
import type { MenuItem } from '../../../typings';
import { isIconUrl } from '../../../utils/isIconUrl';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import LibIcon from '../../../components/LibIcon';

interface Props {
  item: MenuItem;
  index: number;
  scrollIndex: number;
  checked: boolean;
}

const useStyles = createStyles((theme, params: { iconColor?: string }) => ({
  buttonContainer: {
    backgroundColor: 'transparent',
    borderBottom: '1px solid var(--dt-hairline)',
    borderLeft: '2px solid transparent',
    padding: '0 14px',
    height: 64,
    scrollMargin: 8,
    transition: 'background-color 120ms, border-color 120ms',
    '&:focus': {
      backgroundColor: 'var(--dt-select)',
      borderLeftColor: 'var(--dt-accent-light)',
      outline: 'none',
    },
  },
  iconImage: {
    maxWidth: 26,
  },
  buttonWrapper: {
    height: '100%',
  },
  iconContainer: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: 26,
    height: 26,
  },
  icon: {
    fontSize: 24,
    color: params.iconColor || 'var(--dt-accent-light)',
  },
  label: {
    color: 'var(--dt-text-muted)',
    fontFamily: 'var(--dt-font-body)',
    fontWeight: 300,
    textTransform: 'uppercase',
    fontSize: 13,
    letterSpacing: '0.16em',
    lineHeight: 1.4,
  },
  value: {
    color: 'var(--dt-text)',
    fontFamily: 'var(--dt-font-display)',
    fontSize: 18,
    letterSpacing: '0.05em',
    lineHeight: 1.3,
    textShadow: 'var(--dt-shadow-text)',
  },
  chevronIcon: {
    fontSize: 13,
    color: 'var(--dt-accent-light)',
  },
  scrollIndexValue: {
    color: 'var(--dt-text-muted)',
    fontFamily: 'var(--dt-font-body)',
    fontWeight: 300,
    fontSize: 14,
    letterSpacing: '0.08em',
  },
  progressStack: {
    width: '100%',
    marginRight: 5,
  },
  progressLabel: {
    marginBottom: 5,
  },
  progressRoot: {
    backgroundColor: 'rgba(0, 0, 0, 0.55)',
    border: '1px solid var(--dt-hairline)',
    borderRadius: 0,
  },
  progressBar: {
    backgroundColor: 'var(--dt-accent-light)',
  },
}));

const ListItem = forwardRef<Array<HTMLDivElement | null>, Props>(({ item, index, scrollIndex, checked }, ref) => {
  const { classes } = useStyles({ iconColor: item.iconColor });

  return (
    <Box
      tabIndex={index}
      className={classes.buttonContainer}
      key={`item-${index}`}
      ref={(element: HTMLDivElement) => {
        if (ref)
          // @ts-ignore i cba
          return (ref.current = [...ref.current, element]);
      }}
    >
      <Group spacing={14} noWrap className={classes.buttonWrapper}>
        {item.icon && (
          <Box className={classes.iconContainer}>
            {typeof item.icon === 'string' && isIconUrl(item.icon) ? (
              <img src={item.icon} alt="Missing image" className={classes.iconImage} />
            ) : (
              <LibIcon
                icon={item.icon as IconProp}
                className={classes.icon}
                fixedWidth
                animation={item.iconAnimation}
              />
            )}
          </Box>
        )}
        {Array.isArray(item.values) ? (
          <Group position="apart" w="100%">
            <Stack spacing={0} justify="center">
              <Text className={classes.label}>{item.label}</Text>
              <Text className={classes.value}>
                {typeof item.values[scrollIndex] === 'object'
                  ? // @ts-ignore for some reason even checking the type TS still thinks it's a string
                    item.values[scrollIndex].label
                  : item.values[scrollIndex]}
              </Text>
            </Stack>
            <Group spacing={6} position="center">
              <LibIcon icon="chevron-left" className={classes.chevronIcon} />
              <Text className={classes.scrollIndexValue}>
                {scrollIndex + 1}/{item.values.length}
              </Text>
              <LibIcon icon="chevron-right" className={classes.chevronIcon} />
            </Group>
          </Group>
        ) : item.checked !== undefined ? (
          <Group position="apart" w="100%">
            <Text className={classes.value}>{item.label}</Text>
            <CustomCheckbox checked={checked}></CustomCheckbox>
          </Group>
        ) : item.progress !== undefined ? (
          <Stack className={classes.progressStack} spacing={0}>
            <Text className={`${classes.value} ${classes.progressLabel}`}>{item.label}</Text>
            <Progress
              value={item.progress}
              size="sm"
              color={item.colorScheme}
              classNames={
                item.colorScheme
                  ? { root: classes.progressRoot }
                  : { root: classes.progressRoot, bar: classes.progressBar }
              }
            />
          </Stack>
        ) : (
          <Text className={classes.value}>{item.label}</Text>
        )}
      </Group>
    </Box>
  );
});

export default React.memo(ListItem);
