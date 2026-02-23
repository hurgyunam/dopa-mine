import 'package:dopa_mine/models/exercise.dart';

const List<Exercise> kDefaultExercises = <Exercise>[
  Exercise(
    id: 'bird-dog',
    name: 'Bird-dog',
    description: '양손/양무릎 자세에서 반대쪽 팔과 다리를 뻗는 코어 운동',
    targetCount: 10,
    metPoints: 10,
  ),
  Exercise(
    id: 'superman',
    name: 'Superman',
    description: '엎드린 자세에서 팔/다리를 들어 등과 둔근을 강화',
    targetCount: 10,
    metPoints: 12,
  ),
  Exercise(
    id: 'bridge',
    name: 'Bridge',
    description: '누운 자세에서 엉덩이를 들어 코어와 둔근을 활성화',
    targetCount: 12,
    metPoints: 10,
  ),
  Exercise(
    id: 't-raise',
    name: 'T-Raise',
    description: '어깨를 옆으로 열며 상체 안정성을 높이는 운동',
    targetCount: 12,
    metPoints: 8,
  ),
  Exercise(
    id: 'y-raise',
    name: 'Y-Raise',
    description: '팔을 Y자로 들어 올려 등 상부와 어깨를 강화',
    targetCount: 12,
    metPoints: 8,
  ),
];
