package org.example.heritage.service;

import org.example.heritage.pojo.dto.ProjectAddDTO;
import org.example.heritage.pojo.dto.ProjectPageQueryDTO;
import org.example.heritage.pojo.vo.ProjectDetailVO;
import org.example.heritage.pojo.vo.ProjectListVO;

import java.util.List;

public interface ProjectService {

    List<ProjectListVO> list(ProjectPageQueryDTO query);

    Long count(ProjectPageQueryDTO query);

    ProjectDetailVO detail(Integer projectId);

    Integer add(ProjectAddDTO dto);

    void update(Integer projectId, ProjectAddDTO dto);

    void delete(Integer projectId);
}
